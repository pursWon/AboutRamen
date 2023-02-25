import UIKit
import Alamofire
import RealmSwift

class SearchViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var introduceLabel: UILabel!
    
    // MARK: - Properties
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    let regionData = RegionData()
    /// 검색어에 해당되는 String값들의 모음 배열
    var filterArray: [String] = []
    /// 전국에 있는 라멘 가게들의 이름 모음 배열
    var storeNameArray: [String] = []
    /// 중복된 요소를 제거한 전국에 있는 라멘 가게들의 이름 모음 배열
    var uniqueStoreNames: [String] = []
    /// 데이터 송신을 통해 담아온 라멘 가게 정보들의 배열
    var ramenList = List<Information>()
    /// 경도 데이터를 담아줄 변수
    var lng: Double = 0
    /// 위도 데이터를 담아줄 변수
    var lat: Double = 0
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        if let isActive = searchController?.isActive,
           let isSearchTextEmpty = searchController?.searchBar.text?.isEmpty {
            return isActive && !isSearchTextEmpty
        }
        
        return false
    }
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarSetUp()
        setUpSearchController()
        setUpTableView()
        
        let regionList = RegionData.list
        
        for region in regionList {
            let guList = region.guList
    
            for gu in guList {
                getStoreName(lng: gu.location.long, lat: gu.location.lat)
            }
        }
    }
    
    func navigationBarSetUp() {
        navigationController?.navigationBar.backgroundColor = .white
        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Recipekorea", size: 20)!]
        introduceLabel.font = .boldSystemFont(ofSize: 15)
        searchTableView.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    func getStoreName(lng: Double, lat: Double) {
        let headers: HTTPHeaders = ["Authorization" : "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"]
        let parameters: [String : Any] = [
            "query" : "라멘",
            "x" : "\(lng)",
            "y" : "\(lat)",
            "radius" : 7000,
            "size" : 10
        ]
        
        AF.request(url, method: .get, parameters: parameters , headers: headers).responseDecodable(of: RamenStore.self) {
            response in
            if let data = response.value {
                self.ramenList.append(objectsIn: data.documents)
                
                for storeIndex in 0..<data.documents.count {
                    self.storeNameArray.append(data.documents[storeIndex].place_name)
                }
                
                self.uniqueStoreNames = Array(Set(self.storeNameArray))
            } else {
                print("통신 실패")
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
        filterArray = uniqueStoreNames.filter { $0.contains(text) }
        searchTableView.reloadData()
    }
}

// MARK: - TableView
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchTableView.dequeueReusableCell(withIdentifier: "SearchViewCell", for: indexPath) as? SearchViewCell else { return UITableViewCell() }
        
        if isFiltering {
            cell.textLabel?.text = filterArray[indexPath.row]
        } else {
            cell.textLabel?.text = uniqueStoreNames[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        for ramenIndex in 0..<ramenList.count {
            if filterArray[indexPath.row] == ramenList[ramenIndex].place_name {
                detailVC.information = ramenList
                detailVC.index = ramenIndex
            }
        }
        
        let backButton = UIBarButtonItem(title: "가게 검색", style: .plain, target: self, action: nil)
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        
        navigationItem.backBarButtonItem = backButton
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        
        navigationController?.navigationBar.backgroundColor = .systemOrange
        navigationController?.pushViewController(detailVC, animated: true)
    }
}


