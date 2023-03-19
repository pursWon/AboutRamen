import UIKit
import RealmSwift
import Alamofire
import CoreLocation

class MyRamenListViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var myRamenListTableView: UITableView!
    
    enum ViewType: String {
        case ramenList = "나의 라멘 가게"
        case goodList = "좋아요 목록"
    }
    
    // MARK: - Properties
    let realm = try! Realm()
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    var ramenList = List<Information>()
    var viewType: ViewType = .ramenList
    var locationManager = CLLocationManager()
    var currentLocation: (Double?, Double?)
    var distance: String?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewType.rawValue
        setUpTableView()
        view.backgroundColor = CustomColor.beige
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            print("위치 서비스 Off 상태")
        }
    }
    
    func setUpTableView() {
        myRamenListTableView.delegate = self
        myRamenListTableView.dataSource = self
    }
    
    func getData(url: String, storeName: String, x: String, y: String) {
        let headers: HTTPHeaders = ["Authorization": "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"]
        let parameters: [String: Any] = [
            "query" : storeName,
            "x" : x,
            "y" : y
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenStore.self) {
            response in
            if let data = response.value {
                self.ramenList = data.documents
            } else {
                print("통신 실패")
            }
        }
    }
}

// MARK: - TableView
extension MyRamenListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let goodList = realm.objects(GoodListData.self)
        let myRamenList = realm.objects(MyRamenListData.self)
        
        switch title {
        case "좋아요 목록":
            return goodList.count
            
        case "나의 라멘 가게":
            return myRamenList.count
            
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRamenListCell", for: indexPath) as? MyRamenListCell else { return UITableViewCell() }
        let goodList = realm.objects(GoodListData.self)
        let myRamenList = realm.objects(MyRamenListData.self)
        
        switch title {
            
        case "좋아요 목록":
            if !goodList.isEmpty {
                cell.nameLabel.text = goodList[indexPath.row].storeName
                cell.addressLabel.text = goodList[indexPath.row].addressName
                cell.ratingLabel.text = String(goodList[indexPath.row].rating)
                cell.starImage.isHidden = true
            } else {
                cell.starImage.isHidden = true
            }
            
        case "나의 라멘 가게":
            if !myRamenList.isEmpty {
                cell.nameLabel.text = myRamenList[indexPath.row].storeName
                cell.addressLabel.text = myRamenList[indexPath.row].address
                cell.ratingLabel.isHidden = true
            } else {
                cell.ratingLabel.isHidden = true
            }
            
        default:
            fatalError()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        let goodList = realm.objects(GoodListData.self)
        let myRamenList = realm.objects(MyRamenListData.self)
        let myLocation = CLLocation(latitude: currentLocation.0 ?? 0, longitude: currentLocation.1 ?? 0)
        
        switch title {
            
        case "좋아요 목록":
            if goodList.count != 0 {
                let information = ramenList.filter { $0.place_name == goodList[indexPath.row].storeName &&
                    $0.x == String(goodList[indexPath.row].x) &&
                    $0.y == String(goodList[indexPath.row].y)
                }
                
                let goodObject = realm.objects(GoodListData.self).where {
                    $0.storeName == goodList[indexPath.row].storeName &&
                    $0.x == goodList[indexPath.row].x &&
                    $0.y == goodList[indexPath.row].y
                }.first
                
                let myRamenListObject = realm.objects(MyRamenListData.self).where {
                    $0.storeName == goodList[indexPath.row].storeName &&
                    $0.x == goodList[indexPath.row].x &&
                    $0.y == goodList[indexPath.row].y
                }.first
                
                let storeLocation = CLLocation(latitude: goodList[indexPath.row].y, longitude: goodList[indexPath.row].x)
                
                if distance != nil {
                distance = String(format: "%.2f", myLocation.distance(from: storeLocation) / 1000)
                }
                
                if let information = information.first {
                    detailVC.information.append(information)
                    detailVC.goodPressed = goodObject?.isGoodPressed ?? false
                    detailVC.myRamenPressed = myRamenListObject?.myRamenPressed ?? false
                    detailVC.distance = distance
                    detailVC.location.0 = goodList[indexPath.row].x
                    detailVC.location.1 = goodList[indexPath.row].y
                    
                    let backButton = UIBarButtonItem(title: "나의 라멘 가게", style: .plain, target: self, action: nil)
                    let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
                    
                    self.navigationItem.backBarButtonItem = backButton
                    self.navigationItem.backBarButtonItem?.tintColor = .black
                    backButton.setTitleTextAttributes(attributes, for: .normal)
                    
                    navigationController?.pushViewController(detailVC, animated: true)
                }
                
                getData(url: url, storeName: goodList[indexPath.row].storeName, x: String(goodList[indexPath.row].x),
                        y: String(goodList[indexPath.row].y))
            }
            
        case "나의 라멘 가게":
            if myRamenList.count != 0 {
                let information = ramenList.filter { $0.place_name == myRamenList[indexPath.row].storeName &&
                    $0.x == String(myRamenList[indexPath.row].x) &&
                    $0.y == String(myRamenList[indexPath.row].y)
                }
                
                let goodObject = realm.objects(GoodListData.self).where {
                    $0.storeName == myRamenList[indexPath.row].storeName &&
                    $0.x == myRamenList[indexPath.row].x &&
                    $0.y == myRamenList[indexPath.row].y
                }.first
                
                let myRamenListObject = realm.objects(MyRamenListData.self).where {
                    $0.storeName == myRamenList[indexPath.row].storeName &&
                    $0.x == myRamenList[indexPath.row].x &&
                    $0.y == myRamenList[indexPath.row].y
                }.first
                
                let storeLocation = CLLocation(latitude: myRamenList[indexPath.row].y, longitude: myRamenList[indexPath.row].x)
                distance = String(format: "%.2f", myLocation.distance(from: storeLocation) / 1000)
                
                if let information = information.first {
                    
                    detailVC.information.append(information)
                    detailVC.goodPressed = goodObject?.isGoodPressed ?? false
                    detailVC.myRamenPressed = myRamenListObject?.myRamenPressed ?? false
                    detailVC.distance = distance
                    detailVC.location.0 = myRamenList[indexPath.row].x
                    detailVC.location.1 = myRamenList[indexPath.row].y
                    
                    let backButton = UIBarButtonItem(title: "나의 라멘 가게", style: .plain, target: self, action: nil)
                    let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
                    
                    self.navigationItem.backBarButtonItem = backButton
                    self.navigationItem.backBarButtonItem?.tintColor = .black
                    backButton.setTitleTextAttributes(attributes, for: .normal)
                    
                    navigationController?.pushViewController(detailVC, animated: true)
                }
                
                getData(url: url, storeName: myRamenList[indexPath.row].storeName, x: String(myRamenList[indexPath.row].x), y: String(myRamenList[indexPath.row].y))
            }
            
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension MyRamenListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("위도 : \(location.coordinate.latitude)")
            print("경도 : \(location.coordinate.longitude)")
            currentLocation.0 = location.coordinate.latitude
            currentLocation.1 = location.coordinate.longitude
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
