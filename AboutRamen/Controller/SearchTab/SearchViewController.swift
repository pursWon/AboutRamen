import UIKit
import Alamofire
import RealmSwift
import CoreLocation

class SearchViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var introduceLabel: UILabel!
    
    // MARK: - Properties
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    let realm = try! Realm()
    let appid = Bundle.main.apiKey
    var locationManager = CLLocationManager()
    /// 검색어에 해당되는 String값들의 모음 배열
    var filterArray: [String] = []
    /// 전국에 있는 라멘 가게들의 이름 모음 배열
    var storeNames: [String] = []
    /// 데이터 송신을 통해 담아온 라멘 가게 정보들의 배열
    var ramenList = List<Information>()
    var currentLocation: (Double?, Double?)
    var distance: String = "0"
    var isFiltered: Bool {
        let searchController = self.navigationItem.searchController
        
        if let isActive = searchController?.isActive,
           let isSearchTextEmpty = searchController?.searchBar.text?.isEmpty {
            return isActive && !isSearchTextEmpty
        }
        
        return false
    }
    var searchText: String = ""
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarSetUp()
        setUpSearchController()
        setUpTableView()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 ON 상태")
            locationManager.startUpdatingLocation()
        } else {
            print("위치 서비스 OFF 상태")
        }
    }
    
    func navigationBarSetUp() {
        navigationController?.navigationBar.backgroundColor = CustomColor.beige
        
        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Recipekorea", size: 20)!]
        introduceLabel.font = .boldSystemFont(ofSize: 15)
        introduceLabel.backgroundColor = CustomColor.sage
        searchTableView.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    func getRamenData(url: String, currentLocation: (Double, Double)) {
        print(currentLocation.0)
        let headers: HTTPHeaders = ["Authorization": appid]
        let parameters: [String: Any] = [
            "query" : "라멘",
            "x": "\(currentLocation.1)",
            "y": "\(currentLocation.0)",
            "radius": 7000,
            "size": 15,
            "page": 1
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenStore.self) {
            response in
            if let data = response.value {
                self.ramenList = data.documents
                
                for i in 0..<self.ramenList.count {
                    self.storeNames.append(self.ramenList[i].place_name)
                }
                
                DispatchQueue.main.async {
                    self.searchTableView.reloadData()
                }
            }
        }
    }
    
    func setUpSearchController() {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "가게 이름을 입력해주세요"
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        
        navigationItem.searchController = searchController
        navigationItem.title = "가게 검색"
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setUpTableView() {
        searchTableView.dataSource = self
        searchTableView.delegate = self
    }
}

// MARK: - SearchViewController
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        searchText = text
        
        filterArray = storeNames.filter { $0.contains(text) }
        searchTableView.reloadData()
        
        if searchText.isEmpty {
            introduceLabel.text = "현재 지역을 중심으로 가게를 검색해줍니다."
            introduceLabel.backgroundColor = CustomColor.sage
        } else {
            if filterArray.isEmpty {
                introduceLabel.text = "검색결과가 없습니다. 다시시도해주세요."
                introduceLabel.backgroundColor = .gray
            } else {
                introduceLabel.text = "검색 결과 : \(filterArray.count)개"
                introduceLabel.backgroundColor = CustomColor.sage
            }
        }
    }
}

// MARK: - TableView UITableViewDelegate & UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltered {
            return filterArray.count
        } else {
            return storeNames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchTableView.dequeueReusableCell(withIdentifier: "SearchViewCell", for: indexPath) as? SearchViewCell else { return UITableViewCell() }
        
        if isFiltered {
            cell.textLabel?.text = filterArray[indexPath.row]
        } else {
            cell.textLabel?.text = storeNames[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        let myLocation = CLLocation(latitude: currentLocation.0 ?? 0, longitude: currentLocation.1 ?? 0)
        let storeLocation = CLLocation(latitude: Double(ramenList[indexPath.row].y) ?? 0, longitude: Double(ramenList[indexPath.row].x) ?? 0)
        distance = String(format: "%.2f", myLocation.distance(from: storeLocation) / 1000)
        
        let goodList = realm.objects(GoodListData.self)
        let myRamenList = realm.objects(MyRamenListData.self)
        var goodListNames: [String] = []
        var myRamenListNames: [String] = []
        
        for i in 0..<goodList.count {
            goodListNames.append(goodList[i].storeName)
        }
        
        for i in 0..<myRamenList.count {
            myRamenListNames.append(myRamenList[i].storeName)
        }
        
        if isFiltered {
            let information = ramenList.filter { $0.place_name == self.filterArray[indexPath.row] }
            
            detailVC.information.append(objectsIn: information)
            detailVC.distance = distance
            
            if let long = Double(information[indexPath.row].x), let lat = Double(information[indexPath.row].y) {
                detailVC.location.0 = long
                detailVC.location.1 = lat
            }
            
            if goodListNames.contains(filterArray[indexPath.row]) {
                detailVC.goodPressed = true
            } else {
                detailVC.goodPressed = false
            }
            
            if myRamenListNames.contains(filterArray[indexPath.row]) {
                detailVC.myRamenPressed = true
            } else {
                detailVC.myRamenPressed = false
            }
            
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            let information = ramenList.filter { $0.place_name == self.storeNames[indexPath.row] }
            detailVC.information.append(objectsIn: information)
            detailVC.distance = distance
            
            if let long = Double(information[indexPath.row].x), let lat = Double(information[indexPath.row].y) {
                detailVC.location.0 = long
                detailVC.location.1 = lat
            }
            
            if goodListNames.contains(storeNames[indexPath.row]) {
                detailVC.goodPressed = true
            } else {
                detailVC.goodPressed = false
            }
            
            if myRamenListNames.contains(storeNames[indexPath.row]) {
                detailVC.myRamenPressed = true
            } else {
                detailVC.myRamenPressed = false
            }
            
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
        let backButton = UIBarButtonItem(title: "가게 검색", style: .plain, target: self, action: nil)
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        
        navigationItem.backBarButtonItem = backButton
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        
        navigationController?.navigationBar.backgroundColor = CustomColor.beige
    }
}

extension SearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        if let location = locations.first {
            print("위도 : \(location.coordinate.latitude)")
            print("경도 : \(location.coordinate.longitude)")
            currentLocation = (location.coordinate.latitude, location.coordinate.longitude)
            if let lat = currentLocation.0, let long = currentLocation.1 {
                getRamenData(url: url, currentLocation: (lat, long))
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

