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
    /// 검색어를 기반으로 데이터 송신을 통해 담아온 라멘 가게 정보들의 배열
    var ramenList = List<Information>()
    
    var currentLocation: CLLocation?
    var distance: String = ""
    
    var isFiltered: Bool {
        let searchController = self.navigationItem.searchController
        
        if let isActive = searchController?.isActive, let isSearchTextEmpty = searchController?.searchBar.text?.isEmpty {
            return isActive && !isSearchTextEmpty
        }
        
        return false
    }
    /// 검색어
    var searchText: String = ""
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationbar()
        setupSearchController()
        setupTableView()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    // MARK: - Set up
    func setupTableView() {
        searchTableView.dataSource = self
        searchTableView.delegate = self
    }
    
    func setupNavigationbar() {
        navigationController?.navigationBar.backgroundColor = CustomColor.beige
        
        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Recipekorea", size: 20)!]
        introduceLabel.font = .boldSystemFont(ofSize: 15)
        introduceLabel.backgroundColor = CustomColor.sage
        searchTableView.backgroundColor = .white
    }
    
    func setupSearchController() {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "가게 이름을 입력해주세요"
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
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        searchText = text
        filterArray = storeNames.filter { $0.contains(text) }
       
        if searchText.isEmpty {
            introduceLabel.text = "현재 지역을 중심으로 가게를 검색합니다."
            introduceLabel.backgroundColor = CustomColor.sage
        } else {
            if filterArray.isEmpty {
                introduceLabel.text = "검색결과가 없습니다. 다시 시도해 주세요."
                introduceLabel.backgroundColor = .gray
            } else {
                introduceLabel.text = "검색 결과: \(filterArray.count)개"
                introduceLabel.backgroundColor = CustomColor.sage
            }
        }
        
        searchTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltered ? filterArray.count : storeNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchTableView.dequeueReusableCell(withIdentifier: "SearchViewCell", for: indexPath) as? SearchViewCell else { return UITableViewCell() }
        
        cell.textLabel?.text = isFiltered ? filterArray[indexPath.row] : storeNames[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        // 렘에 저장한 라면 리스트
        let storedRamenList = realm.objects(RamenData.self)
        
        var searchResults: [String] = []
        
        if isFiltered {
            let goodList = storedRamenList.filter{ $0.isGood }
            let selectedRamen = Array(goodList)[indexPath.row]
            detailVC.viewType = .search
            detailVC.selectedRamen = selectedRamen
        } else {
            let myRamenList = storedRamenList.filter{ $0.isFavorite }
            let selectedRamen = Array(myRamenList)[indexPath.row]
            detailVC.selectedRamen = selectedRamen
            
        }
        
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
