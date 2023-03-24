import UIKit
import CoreLocation
import Alamofire
import Kingfisher
import RealmSwift

// MARK: - Protocols
protocol LocationDataProtocol {
    func sendCurrentLocation(location: (long: Double, lat: Double))
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
    let realm = try! Realm()
    /// kakao 키워드 검색 API 주소
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    /// kakao 키워드 이미지 검색 API 주소
    let imageUrl: String = "https://dapi.kakao.com/v2/search/image"
    let appid = Bundle.main.apiKey
    /// API를 통해서 가져온 라멘집 리스트 정보를 담고 있는 배열
    var ramenList: List<Information>?
    /// 라멘집 이미지들의 image_url 값들의 배열
    var imageUrlList: [String] = []
    var regionLocation: (long: Double, lat: Double) = (RegionData.list[0].guList[0].location.long, RegionData.list[0].guList[0].location.lat)
    var storeNames: [String] = []
    var allRamenData: List<Information>?
    var locationManager = CLLocationManager()
    var currentLocation: (long: Double?,lat: Double?)
    var distance: String?
    var goodStoreName: [String] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView()
        setUpNavigationBar()
        
        myLocationLabel.text = "\(RegionData.list[0].city.rawValue) \(RegionData.list[0].guList[0].gu)"
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        /// - NOTE : coordinate 확인을 위해 프린트문 유지,,
        if CLLocationManager.locationServicesEnabled() {
            // print("위치 서비스 On 상태")
            locationManager.startUpdatingLocation()
            // print(locationManager.location?.coordinate)
        } else {
            // print("위치 서비스 Off 상태")
        }
        
        view.backgroundColor = CustomColor.beige
        /// - NOTE : Realm 파일 위치를 확인하기 위해 프린트문 유지...
        // print(realm.configuration.fileURL)
        
        let goodList = realm.objects(GoodListData.self)
        goodList.forEach { goodStoreName.append($0.storeName) }
        
        getRamenData(url: url, currentLocation: regionLocation)
    }

    func setUpNavigationBar() {
        title = "어바웃라멘"
        navigationController?.navigationBar.backgroundColor = CustomColor.beige
        
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
        collectionView.backgroundColor = CustomColor.beige
    }
    
    func getRamenData(url: String, currentLocation: (long: Double, lat: Double)) {
        let headers: HTTPHeaders = ["Authorization": appid]
        let parameters: [String: Any] = [
            "query" : "라멘",
            "x": "\(currentLocation.long)",
            "y": "\(currentLocation.lat)",
            "radius": 7000,
            "size": 10,
            "page": 1
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenStore.self) {
            response in
            if let data = response.value {
                self.ramenList = data.documents
                guard let ramenList = self.ramenList else { return }
                ramenList.forEach{ self.storeNames.append($0.place_name) }

                DispatchQueue.main.async {
                    self.getRamenImages()
                }
            }
        }
    }
    
    func getRamenImages() {
        imageUrlList.removeAll()
        
        let headers: HTTPHeaders = ["Authorization": appid]
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

// MARK: - CollectionView Delegate & Datasource
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
        // TODO: 좋아요 리스트를 통해서 홈 vc에서 별점을 보여줄 예정
        let goodList = realm.objects(GoodListData.self)
        let ramenData = ramenList[indexPath.row]
        let myLocation = CLLocation(latitude: currentLocation.long ?? 0, longitude: currentLocation.lat ?? 0)
        let storeLocation = CLLocation(latitude: Double(ramenList[indexPath.row].y) ?? 0, longitude: Double(ramenList[indexPath.row].x) ?? 0)
        
        distance = String(format: "%.2f" , myLocation.distance(from: storeLocation) / 1000)
        
        cell.cellConfigure()
        cell.nameLabel.text = ramenData.place_name
        
        if let distance = distance {
        cell.distanceLabel.text = "\(distance)km"
        }
        
        cell.ramenImageView.layer.borderWidth = 1.5
        cell.ramenImageView.layer.borderColor = UIColor.black.cgColor
        cell.ramenImageView.layer.cornerRadius = 10
            
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
        detailVC.store = ramenList[indexPath.row].place_name
        
        if let x = Double(ramenList[indexPath.row].x), let y = Double(ramenList[indexPath.row].y) {
            detailVC.location = (x,y)
        }
        
        let goodData = realm.objects(GoodListData.self).filter {
            $0.storeName == ramenList[indexPath.row].place_name &&
            $0.x == Double(ramenList[indexPath.row].x) &&
            $0.y == Double(ramenList[indexPath.row].y)
        }
        
        detailVC.goodPressed = goodData.isEmpty ? false : true
        
        let myRamenData = realm.objects(MyRamenListData.self).filter {
            $0.storeName == ramenList[indexPath.row].place_name &&
            $0.x == Double(ramenList[indexPath.row].x) &&
            $0.y == Double(ramenList[indexPath.row].y)
        }
        
        detailVC.myRamenPressed = myRamenData.isEmpty ? false : true
        
        let reviewListData = realm.objects(ReviewListData.self).filter {
            $0.storeName == ramenList[indexPath.row].place_name &&
            $0.addressName == ramenList[indexPath.row].road_address_name
        }
        
        detailVC.reviewState = reviewListData.isEmpty ? .yet : .done
        
        detailVC.index = indexPath.row
        detailVC.information = ramenList
        if let distance = distance {
        detailVC.distance = distance
        }
        
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
    func sendCurrentLocation(location: (long: Double, lat: Double)) {
        regionLocation = location
        getRamenData(url: url, currentLocation: regionLocation)
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = (Double(location.coordinate.latitude), Double(location.coordinate.longitude))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
