import UIKit
import RealmSwift
import Alamofire
import CoreLocation

class MyRamenListViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var emptyLabel: UILabel!
    @IBOutlet var myRamenListTableView: UITableView!
    
    // MARK: - Properties
    let realm = try! Realm()
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    let appid = Bundle.main.apiKey
    /// API로부터 가져온 라멘 가게 리스트
    var ramenList = List<Information>()
    var distance: String?
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    enum ViewType: String {
        case goodList = "좋아요 목록"
        case favoriteList = "나의 라멘 가게"
    }
    
    var viewType: ViewType = .goodList
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewType.rawValue
        view.backgroundColor = CustomColor.beige
        setUpTableView()
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myRamenListTableView.reloadData()
    }
    
    // MARK: - Set up
    func setUpTableView() {
        myRamenListTableView.delegate = self
        myRamenListTableView.dataSource = self
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - API
    func getData(url: String, storeName: String, x: String, y: String) {
        let headers: HTTPHeaders = ["Authorization": appid]
        let parameters: [String: Any] = [
            "query": storeName,
            "x": x,
            "y": y
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenStore.self) { response in
            if let data = response.value {
                self.ramenList = data.documents
            } else {
                print("통신 실패")
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MyRamenListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewType {
        case .goodList:
            let goodList = realm.objects(RamenData.self).filter { $0.isGood }
            emptyLabel.isHidden = goodList.isEmpty ? false : true
            return goodList.count
            
        case .favoriteList:
            let favoriteList = realm.objects(RamenData.self).filter { $0.isFavorite }
            emptyLabel.isHidden = favoriteList.isEmpty ? false : true
            return favoriteList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRamenListCell", for: indexPath) as? MyRamenListCell else { return UITableViewCell() }
        cell.starImage.tintColor = .systemOrange
        
        switch viewType {
        case .goodList:
            let goodList = realm.objects(RamenData.self).filter { $0.isGood }
            let item = goodList[indexPath.row]
            cell.nameLabel.text = item.storeName
            cell.addressLabel.text = item.addressName
            cell.ratingLabel.text = String(item.rating)
            cell.starImage.image = UIImage(systemName: "heart.fill")
            return cell
            
        case .favoriteList:
            let favoriteList = realm.objects(RamenData.self).filter { $0.isFavorite }
            let item = favoriteList[indexPath.row]
            cell.nameLabel.text = item.storeName
            cell.addressLabel.text = item.addressName
            cell.ratingLabel.isHidden = true
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        switch viewType {
        case .goodList:
            let goodList = realm.objects(RamenData.self).filter { $0.isGood }
            
            guard !goodList.isEmpty else { return }
            let selectedRamen = goodList[indexPath.row]
            let targetLocation = CLLocation(latitude: selectedRamen.y, longitude: selectedRamen.x)
            detailVC.distance = getDistance(from: currentLocation, to: targetLocation)
            detailVC.viewType = .goodList
            detailVC.selectedRamen = selectedRamen
            
            // getData(url: url, storeName: goodList[indexPath.row].storeName, x: String(goodList[indexPath.row].x), y: String(goodList[indexPath.row].y))
            
        case .favoriteList:
            let favoriteList = realm.objects(RamenData.self).filter { $0.isFavorite }
            
            guard !favoriteList.isEmpty else { return }
            let selectedRamen = favoriteList[indexPath.row]
            let targetLocation = CLLocation(latitude: selectedRamen.y, longitude: selectedRamen.x)
            detailVC.distance = getDistance(from: currentLocation, to: targetLocation)
            detailVC.viewType = .favoriteList
            detailVC.selectedRamen = selectedRamen
            
            // ???: 무슨 함수인지 체크
            // getData(url: url, storeName: favoriteList[indexPath.row].storeName, x: String(favoriteList[indexPath.row].x), y: String(favoriteList[indexPath.row].y))
        }
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - CLLocationManagerDelegate
extension MyRamenListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
