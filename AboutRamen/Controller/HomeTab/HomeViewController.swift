import UIKit
import Alamofire
import Kingfisher

// TODO: 프로토콜 이름 변경해볼것!
protocol LocationDataProtocol {
    func sendCurrentLocation(lnglat: (Double, Double))
}

protocol RegionDataProtocol {
    func sendRegionData(city: String, gu: String)
}

class HomeViewController: UIViewController {
    // MARK: - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var regionChangeButton: UIBarButtonItem!
    @IBOutlet var myLocationLabel: UILabel!
    
    // MARK: - Properties
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    let imageUrl: String = "https://dapi.kakao.com/v2/search/image"
    let regionData = RegionData()
    /// API를 통해서 가져온 라멘집 리스트 정보를 담고 있는 배열
    var ramenList: [Information] = []
    /// 라멘집 이미지들의 image_url 값들의 배열
    var imageUrlList: [String] = []
    var currentLocation: (long: Double, lat: Double) = (127.0495556, 37.514575)
    var storeNames: [String] = []
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView()
        setUpNavigationBar()
        myLocationLabel.text = "서울시 강남구"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRamenData(url: url, lnglat: currentLocation)
    }
    
    func setUpNavigationBar() {
        title = "어바웃라멘"
        view.backgroundColor = .systemOrange
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "BlackHanSans-Regular", size: 20)!]
        regionChangeButton.setTitleTextAttributes(attributes, for: .normal)
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "BlackHanSans-Regular", size: 30)!]
        }
        
        myLocationLabel.font = UIFont.init(name: "RecipeKorea", size: 17)
    }
    
    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemOrange
    }
    // TODO: 변수명 수정하기
    func getRamenData(url: String, lnglat: (Double, Double)) {
        let headers: HTTPHeaders = ["Authorization": "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"]
        
        let parameters: [String: Any] = [
            "query" : "라멘",
            "x": "\(lnglat.0)",
            "y": "\(lnglat.1)",
            "radius": 10000,
            "size": 15,
            "page": 1
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenStore.self) { response in
            if let data = response.value {
                self.ramenList = data.documents
                
                for index in 0..<self.ramenList.count {
                    self.storeNames.append(self.ramenList[index].place_name)
                }
                
                DispatchQueue.main.async {
                    self.getRamenImages()
                }
            }
        }
    }
    
    func getRamenImages() {
        let headers: HTTPHeaders = ["Authorization": "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"]
        for name in storeNames {
            let params: [String: Any] = ["query": name]
            AF.request(imageUrl, method: .get, parameters: params, headers: headers).responseDecodable(of: RamenImage.self) { response in
                if let dataImage = response.value {
                    self.imageUrlList.append(dataImage.documents[2].image_url)
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    @IBAction func regionChangeButton(_ sender: UIBarButtonItem) {
        guard let regionPickerVC = self.storyboard?.instantiateViewController(withIdentifier: "RegionPickerController") as? RegionPickerController else { return }
        
        regionPickerVC.delegateRegion = self
        regionPickerVC.delegateLocation = self
        
        let backButton = UIBarButtonItem(title: "홈", style: .plain, target: self, action: nil)
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        
        self.navigationItem.backBarButtonItem = backButton
        self.navigationItem.backBarButtonItem?.tintColor = .black
        backButton.setTitleTextAttributes(attributes, for: .normal)
        navigationController?.pushViewController(regionPickerVC, animated: true)
    }
}

// MARK: - Collecion View
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ramenList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        let ramenData = ramenList[indexPath.row]
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 3
        cell.layer.cornerRadius = 10
        
        cell.nameLabel.textAlignment = .left
        cell.nameLabel.font = .boldSystemFont(ofSize: 12)
        cell.starLabel.font = .boldSystemFont(ofSize: 15)
        
        cell.nameLabel.text = ramenData.place_name
        cell.distanceLabel.text = "\(ramenData.distance) m"
        
        if imageUrlList.count == ramenList.count {
            let url = URL(string: imageUrlList[indexPath.row])
            cell.ramenImageView.kf.setImage(with: url)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        let widthSpacing: CGFloat = 20
        let heightSpacing: CGFloat = 60
        let widthCount: CGFloat = 2
        let heightCount: CGFloat = 3
        let totalWidth = (width - (widthSpacing * (widthCount - 1))) / widthCount
        let totalHeight = (height - (heightSpacing * (heightCount - 1))) / heightCount
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.index = indexPath.row
        detailVC.information = ramenList
        
        let backButton = UIBarButtonItem(title: "홈", style: .plain, target: self, action: nil)
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        
        self.navigationItem.backBarButtonItem = backButton
        self.navigationItem.backBarButtonItem?.tintColor = .black
        backButton.setTitleTextAttributes(attributes, for: .normal)
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - RegionProtocol
extension HomeViewController: RegionDataProtocol {
    func sendRegionData(city: String, gu: String) {
        myLocationLabel.text = "\(city) \(gu)"
    }
}

// MARK: - LngLatProtocol
extension HomeViewController: LocationDataProtocol {
    func sendCurrentLocation(lnglat: (Double, Double)) {
        currentLocation = lnglat
    }
}
