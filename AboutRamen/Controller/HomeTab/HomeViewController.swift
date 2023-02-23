import UIKit
import Alamofire
import Kingfisher
import RealmSwift

protocol LocationDataProtocol {
    func sendCurrentLocation(longlat: (Double, Double))
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
    var ramenList: List<Information>?
    /// 라멘집 이미지들의 image_url 값들의 배열
    var imageUrlList: [String] = []
    var currentLocation: (long: Double, lat: Double) = (127.0277194, 37.63695556)
    var storeNames: [String] = []
    var realmDataStorage: [RealmData] = []
    let realm = try! Realm()
    var uniqueRealmData: LazyFilterSequence<List<Information>>?
    var ramen = List<Information>()

    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        setUpNavigationBar()
        myLocationLabel.text = "서울시 강북구"
        // myLocationLabel.text = "서울시 강남구"
        print(realm.configuration.fileURL)
        
        let regionList = RegionData.list
        for region in regionList {
            let guList = region.guList
            
            for gu in guList {
                putInRealmData(lng: gu.location.long, lat: gu.location.lat)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRamenData(url: url, currentLocation : currentLocation)
        imageUrlList.removeAll()
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
    
    func putInRealmData(lng: Double, lat: Double) {
        let headers: HTTPHeaders = ["Authorization" : "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"]
        let parameters: [String : Any] = [
            "query" : "라멘",
            "x" : "\(lng)",
            "y" : "\(lat)",
            "radius" : 7000,
            "size" : 10
        ]
        
        AF.request(url, method: .get, parameters: parameters ,headers: headers).responseDecodable(of: RamenStore.self) {
            response in
            let unique = List<Information>()
            if let data = response.value {
                self.ramen.append(objectsIn: data.documents)
            }
            let allRealmData = self.realm.objects(RealmData.self)
            
            
        }
    }
    
    func removeDuplicate (_ array: [RealmData]) -> [RealmData] {
        var removedArray = [RealmData]()

        for i in array {
            if !removedArray.contains(i) {
                removedArray.append(i)
            }
        }
        
        return removedArray
    }
    
    func getRamenData(url: String, currentLocation: (Double, Double)) {
        let headers: HTTPHeaders = ["Authorization": "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"]
        let parameters: [String: Any] = [
            "query" : "라멘",
            "x": "\(currentLocation.0)",
            "y": "\(currentLocation.1)",
            "radius": 7000,
            "size": 10,
            "page": 1
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenStore.self) {
            response in
            if let data = response.value {
                self.ramenList = data.documents
                guard let ramenList = self.ramenList else { return }
                
                for index in 0..<ramenList.count {
                    self.storeNames.append(ramenList[index].place_name)
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
                    for i in 0..<dataImage.documents.count {
                        if i == 0 {
                            self.imageUrlList.append(dataImage.documents[0].image_url)
                        }
                    }
                    self.storeNames.removeAll()
                } else {
                    
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
        if let ramenList = ramenList {
            return ramenList.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        guard let ramenList = ramenList else { return UICollectionViewCell() }
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
        } else {
            cell.ramenImageView.image = UIImage(named: "Ramen")
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
        guard let ramenList = ramenList else { return }
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

// MARK: - LocationDataProtocol
extension HomeViewController: LocationDataProtocol {
    func sendCurrentLocation(longlat: (Double, Double)) {
        currentLocation = longlat
    }
}
