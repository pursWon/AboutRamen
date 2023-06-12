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

let region = load()

/// 홈 화면
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
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    /// API를 통해서 가져온 라멘집 리스트 정보를 담고 있는 배열
    var ramenList: List<Information>?
    /// 라멘집 이미지들의 image_url 값들의 배열
    var imageUrlList: [String] = []
    var storeNames: [String] = []
    var goodStoreName: [String] = []
    var distance: String?
    
    var regionLocation: CLLocation?
    var regionData: RegionInformation?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let region = region {
            guard let regionInformation = try? JSONDecoder().decode(RegionInformation.self, from: region) else
            { return }
            
            regionData = regionInformation
            regionLocation = CLLocation(latitude: regionInformation.region[0].local[0].latitude, longitude: regionInformation.region[0].local[0].longtitude)
        }
        
        /// - NOTE: Realm 위치 찾을 때 사용
        // print(">>> location: \(realm.configuration.fileURL)")
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            setInitData()
        }
        
        setLocationManager()
        setUpCollectionView()
        setupNavigationbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        deleteNoDataItem()
        collectionView.reloadData()
    }
    
    // MARK: - Set Up
    func setInitData() {
        view.backgroundColor = CustomColor.beige
        
        guard let regionData = regionData else { return }
        myLocationLabel.text = "\(regionData.region[0].city) \(regionData.region[0].local[0].gu)"
        
        let goodList = realm.objects(RamenData.self)
        goodList.forEach{ goodStoreName.append($0.storeName) }
        
        guard let regionLocation = regionLocation else { return }
        getRamenData(url: url, currentLocation: regionLocation)
    }
    
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setupNavigationbar() {
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
    
    // MARK: - API
    func getRamenData(url: String, currentLocation: CLLocation) {
        storeNames.removeAll()
        
        let headers: HTTPHeaders = ["Authorization": appid]
        let parameters: [String: Any] = [
            "query" : "라멘",
            "x": "\(currentLocation.coordinate.longitude)",
            "y": "\(currentLocation.coordinate.latitude)",
            "radius": 7000,
            "size": 10,
            "page": 1
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenStore.self) { response in
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
                    
                    if !dataImage.documents.isEmpty {
                        self.imageUrlList.append(dataImage.documents[0].image_url)
                    }
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - ETC
    /// 평가가 모두 안되어 있는 아이템 삭제
    func deleteNoDataItem() {
        let shouldDeleteItems = realm.objects(RamenData.self).filter{ !$0.isGood && !$0.isReviewed && !$0.isFavorite }
        
        if !shouldDeleteItems.isEmpty {
            try! realm.write {
                realm.delete(shouldDeleteItems)
            }
        }
    }
    
    func isReviewExist(item: Information) -> Bool {
        let reviewList = realm.objects(RamenData.self).filter{ $0.isReviewed }.filter{
            $0.storeName == item.place_name
            && String($0.x) == item.x
            && String($0.y) == item.y
        }
        
        return !reviewList.isEmpty
    }
    
    // MARK: - Action
    @IBAction func regionChangeButton(_ sender: UIBarButtonItem) {
        guard let regionPickerVC = self.storyboard?.instantiateViewController(withIdentifier: "RegionPickerController") as? RegionPickerController else { return }
        regionPickerVC.delegateRegion = self
        regionPickerVC.delegateLocation = self
        setCustomBackButton(title: "어바웃라멘")
        navigationController?.pushViewController(regionPickerVC, animated: true)
    }
}

// MARK: - CollectionView Delegate & Datasource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let ramenList = ramenList else { return 0 }
        
        return ramenList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell,
            let ramenList = ramenList
        else { return UICollectionViewCell() }
        
        let ramenData = ramenList[indexPath.row].toRameDataType()
        
        cell.cellConfigure()
        
        // 거리
        let targetLocation = CLLocation(latitude: ramenData.y, longitude: ramenData.x)
        cell.distanceLabel.text = getDistance(from: currentLocation, to: targetLocation)
        
        // 별점
        let goodList = realm.objects(RamenData.self)
        
        if !goodList.isEmpty {
            let existItem = goodList.filter {
                $0.x == ramenData.x
                && $0.y == ramenData.y
            }
            
            if let item = existItem.first {
                cell.starLabel.text = "⭐️ \(item.rating) "
            } else {
                cell.starLabel.text = "별점 없음 "
            }
        } else {
            cell.starLabel.text = "별점 없음 "
        }
        
        // 이미지
        if imageUrlList.count == ramenList.count {
            let url = URL(string: imageUrlList[indexPath.row])
            cell.ramenImageView.kf.setImage(with: url)
        } else {
            cell.ramenImageView.image = CustomImage.ramen
        }
        
        // 가게 이름
        cell.nameLabel.text = ramenData.storeName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let widthSpacing: CGFloat = 20
        let widthCount: CGFloat = 2
        let totalWidth = (width - (widthSpacing * (widthCount - 1))) / widthCount
        
        return CGSize(width: totalWidth, height: totalWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController,
            let ramenList = ramenList
        else { return }
        
        let ramen = ramenList[indexPath.row]
        let converted = ramen.toRameDataType()
        
        let realmList = realm.objects(RamenData.self).where {
            $0.storeName == ramen.place_name
            && $0.x == converted.x
            && $0.y == converted.y
        }
        
        if let matchItem = realmList.first {
            detailVC.selectedRamen = matchItem
        } else {
            detailVC.selectedRamen = converted
        }
        
        detailVC.reviewState = isReviewExist(item: ramen) ? .done : .yet
        setCustomBackButton(title: "홈")
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
        regionLocation = CLLocation(latitude: location.lat, longitude: location.long)
        
        guard let regionLocation = regionLocation else { return }
        getRamenData(url: url, currentLocation: regionLocation)
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            self.locationManager.startUpdatingLocation()
            setInitData()
        case .restricted, .notDetermined:
            getLocationUsagePermission()
        case .denied:
            getLocationUsagePermission()
        default:
            print("위치 권한 설정 없음")
        }
    }
}

