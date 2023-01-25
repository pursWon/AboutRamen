import UIKit
import Alamofire

class SearchViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var introduceLabel: UILabel!
    @IBOutlet var searchTabBar: UITabBarItem!
    
    // MARK: - Properties
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    let regionData = RegionData()
    var filterArray: [String] = []
    var storeNameArray: [String] = []
    var ramenList: [Information] = []
    var lng: Double = 0.0
    var lat: Double = 0.0
    var placeName: String = ""
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        
        return isActive && isSearchBarHasText
    }
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.backgroundColor = .white
        setUpSearchController()
        setUpTableView()
        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Recipekorea", size: 20)!]
        for i in regionData.LngLat {
            getStoreName(lng: i.value.0, lat: i.value.1)
        }
        introduceLabel.font = .boldSystemFont(ofSize: 15)
        searchTableView.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    func getStoreName(lng: Double, lat: Double) {
        let headers: HTTPHeaders = [
            "Authorization" : "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"
        ]
        
        let parameters: [String : Any] = [
            "query" : "라멘",
            "x" : "\(lng)",
            "y" : "\(lat)",
            "radius" : 7000,
            "size" : 15
        ]
        
        AF.request(url, method: .get, parameters: parameters ,headers: headers).responseDecodable(of: RamenStore.self) {
            response in
            debugPrint("response.value : \(response.value)")
            
            if let data = response.value {
                
                for i in 0..<data.documents.count {
                    self.ramenList.append(data.documents[i])
                }
                
                for j in 0..<data.documents.count {
                    self.storeNameArray.append(data.documents[j].place_name)
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
        
        self.filterArray = self.storeNameArray.filter { $0.contains(text) }
        self.searchTableView.reloadData()
    }
}

// MARK: - TableView
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.searchTableView.dequeueReusableCell(withIdentifier: "SearchViewCell", for: indexPath) as? SearchViewCell else { return UITableViewCell() }
        
        if self.isFiltering {
            cell.textLabel?.text = self.filterArray[indexPath.row]
        } else {
            cell.textLabel?.text = self.storeNameArray[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        for i in 0..<ramenList.count {
            if filterArray[indexPath.row] == ramenList[i].place_name {
                detailVC.information = ramenList
                detailVC.index = i
            }
        }
        
        let backButton = UIBarButtonItem(title: "가게 검색", style: .plain, target: self, action: nil)
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        
        navigationItem.backBarButtonItem = backButton
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        
        self.navigationController?.navigationBar.backgroundColor = .systemOrange
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}


