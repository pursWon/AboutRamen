import UIKit
import CoreLocation
import Alamofire
import RealmSwift

/// 검색 화면
class SearchViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var introduceLabel: UILabel!
    
    // MARK: - Properties
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    let realm = try! Realm()
    let appid = Bundle.main.apiKey
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    /// 검색어를 기반으로 선별된 가게 정보들의 배열
    var searchedList: [RamenData] = []
    /// 현재 위치를 기반으로 데이터 송신을 통해 담아온 라멘 가게 정보들의 배열
    var defaultList: [RamenData] = []
    var isFiltered: Bool {
        let searchController = self.navigationItem.searchController
        
        if let isActive = searchController?.isActive, let isSearchTextEmpty = searchController?.searchBar.text?.isEmpty {
            return isActive && !isSearchTextEmpty
        }
        
        return false
    }
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocationManager()
        setupNavigationbar()
        setupSearchController()
        setupTableView()
        
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
            setInitData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        deleteNoDataItem()
        
        if let coordinate = currentLocation?.coordinate {
            getRamenData(url: url, currentLocation: (coordinate.latitude, coordinate.longitude))
        }
    }
    
    // MARK: - Set Up
    func setInitData() {
        view.backgroundColor = .white
        introduceLabel.font = .boldSystemFont(ofSize: 15)
        introduceLabel.backgroundColor = CustomColor.sage
        introduceLabel.font = UIFont(name: "Recipekorea", size: 14)
        searchTableView.backgroundColor = .white
    }
    
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setupTableView() {
        searchTableView.dataSource = self
        searchTableView.delegate = self
    }
    
    func setupNavigationbar() {
        navigationController?.navigationBar.backgroundColor = CustomColor.beige
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Recipekorea", size: 20)!]
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Recipekorea", size: 14)!]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
    }
    
    func setupSearchController() {
        let searchController = UISearchController()
        let atrString = NSAttributedString(string: "가게 이름을 입력해주세요", attributes: [.font: UIFont(name: "S-CoreDream-4Regular", size: 13)!])
        
        searchController.searchBar.searchTextField.attributedPlaceholder = atrString
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        
        navigationItem.searchController = searchController
        navigationItem.title = "가게 검색"
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - API
    func getRamenData(url: String, currentLocation: (Double, Double)) {
        let headers: HTTPHeaders = ["Authorization": appid]
        let parameters: [String: Any] = [
            "query" : "라멘",
            "x": "\(currentLocation.1)",
            "y": "\(currentLocation.0)",
            "radius": 7000,
            "size": 15,
            "page": 1
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenStore.self) { response in
            if let data = response.value {
                self.defaultList = []
                self.searchedList = []
                
                for ramen in data.documents {
                    self.defaultList.append(ramen.toRameDataType())
                }
                
                DispatchQueue.main.async {
                    self.searchTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - ETC
    /// 평가가 모두 안되어 있는 아이템 삭제
    func deleteNoDataItem() {
        let shouldDeleteItems = realm.objects(RamenData.self).filter { !$0.isGood && !$0.isReviewed && !$0.isFavorite }
        
        if !shouldDeleteItems.isEmpty {
            try! realm.write {
                realm.delete(shouldDeleteItems)
            }
        }
    }
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        searchedList = defaultList.filter { $0.storeName.contains(text) }
        
        if text.isEmpty {
            introduceLabel.text = "현재 지역을 중심으로 가게를 검색합니다."
            introduceLabel.backgroundColor = CustomColor.sage
        } else {
            if searchedList.isEmpty {
                introduceLabel.text = "검색결과가 없습니다. 다시 시도해 주세요."
                introduceLabel.backgroundColor = .gray
            } else {
                introduceLabel.text = "검색 결과: \(searchedList.count)개"
                introduceLabel.backgroundColor = CustomColor.sage
            }
        }
        
        searchTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltered ? searchedList.count : defaultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchTableView.dequeueReusableCell(withIdentifier: "SearchViewCell", for: indexPath) as? SearchViewCell else { return UITableViewCell() }
        
        if isFiltered {
            cell.textLabel?.text = searchedList[indexPath.row].storeName
            cell.textLabel?.font = UIFont(name: "Recipekorea", size: 15)
        } else {
            cell.textLabel?.text = defaultList[indexPath.row].storeName
            cell.textLabel?.font = UIFont(name: "Recipekorea", size: 15)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        if isFiltered {
            let realmList = realm.objects(RamenData.self).where {
                $0.storeName == searchedList[indexPath.row].storeName
                && $0.x == searchedList[indexPath.row].x
                && $0.y == searchedList[indexPath.row].y
            }
            
            if let selectedRamen = realmList.first {
                detailVC.viewType = .search
                detailVC.selectedRamen = selectedRamen
            } else {
                let selectedRamen = searchedList[indexPath.row]
                detailVC.viewType = .search
                detailVC.selectedRamen = selectedRamen
            }
        } else {
            let realmList = realm.objects(RamenData.self).where {
                $0.storeName == defaultList[indexPath.row].storeName
                && $0.x == defaultList[indexPath.row].x
                && $0.y == defaultList[indexPath.row].y
            }
            
            if let selectedRamen = realmList.first {
                detailVC.viewType = .search
                detailVC.selectedRamen = selectedRamen
            } else {
                let selectedRamen = defaultList[indexPath.row]
                detailVC.viewType = .search
                detailVC.selectedRamen = selectedRamen
            }
        }
        
        setCustomBackButton(title: "가게 검색")
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension SearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
            
            guard let currentLocation = currentLocation else { return }
            let lat = currentLocation.coordinate.latitude
            let long = currentLocation.coordinate.longitude
            getRamenData(url: url, currentLocation: (lat, long))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
