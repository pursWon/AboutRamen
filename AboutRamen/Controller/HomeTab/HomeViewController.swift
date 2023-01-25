import UIKit
import Alamofire

class HomeViewController: UIViewController, RegionDataProtocol, LngLatProtocol {
    // MARK: - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var regionChangeButton: UIBarButtonItem!
    @IBOutlet var myLocationLabel: UILabel!
    
    // MARK: - Properties
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    let imageUrl: String = "https://dapi.kakao.com/v2/search/image"
    var ramenList: [Information] = []
    var ramenImage: [Image] = []
    var ramenCellImage: String = ""
    var ramenCellImages: [String] = []
    var region: String = ""
    let regionData = RegionData()
    var myLngLat: (Double, Double) = (127.0495556, 37.514575)
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView()
        setUpNavigationBar()
        getAlamofire(url: url, lnglat: myLngLat)
        myLocationLabel.text = "서울시 강남구"
    }
    
    func sendRegionData(city: String, gu: String) {
        myLocationLabel.text = "\(city) \(gu)"
    }
    
    func sendLngLgt(lnglat: (Double, Double)) {
        myLngLat = lnglat
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAlamofire(url: url, lnglat: myLngLat)
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
    
    func getAlamofire(url: String, lnglat: (Double, Double)) {
        
        let headers: HTTPHeaders = [
            "Authorization" : "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"
        ]
        
        let parameters: [String : Any] = [
            "query" : "라멘",
            "x" : "\(lnglat.0)",
            "y" : "\(lnglat.1)",
            "radius" : 7000,
            "size" : 15
        ]
        
        AF.request(url, method: .get, parameters: parameters ,headers: headers).responseDecodable(of: RamenStore.self) {
            response in
            debugPrint("response.value : \(response.value)")
            
            if let data = response.value {
                self.ramenList = data.documents
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func getRamenImage(imageURL: String ,query: String) {
    
        let headers: HTTPHeaders = [
            "Authorization" : "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"
        ]
        
        let parameters: [String : Any] = [
            "query" : query
        ]
    
        AF.request(imageUrl, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenImage.self) {
            response in
            
            if let dataImage = response.value {
                self.ramenImage = dataImage.documents
                self.ramenCellImage = self.ramenImage[0].image_url
                self.ramenCellImages.append(self.ramenCellImage)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    @IBAction func regionChangeButton(_ sender: UIBarButtonItem) {
        guard let regionPickerVC = self.storyboard?.instantiateViewController(withIdentifier: "RegionPickerController") as? RegionPickerController else { return }
        
        regionPickerVC.delegate = self
        regionPickerVC.delegateLngLgt = self
        
        let backButton = UIBarButtonItem(title: "홈", style: .plain, target: self, action: nil)
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        
        self.navigationItem.backBarButtonItem = backButton
        self.navigationItem.backBarButtonItem?.tintColor = .black
        backButton.setTitleTextAttributes(attributes, for: .normal)
        navigationController?.pushViewController(regionPickerVC, animated: true)
    }
}

// MARK: - Collecion View
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ramenList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        
        let ramenData = ramenList[indexPath.row]
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 3
        cell.layer.cornerRadius = 10
        
        cell.nameLabel.textAlignment = .center
        cell.nameLabel.font = .boldSystemFont(ofSize: 15)
        cell.starLabel.font = .boldSystemFont(ofSize: 15)
        
        cell.nameLabel.text = ramenData.place_name
        cell.distanceLabel.text = "\(ramenData.distance) m"
      
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