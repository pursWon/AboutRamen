import UIKit
import CoreLocation
import Alamofire
import RealmSwift

/// 검색 화면
class SearchViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var introduceLabel: UILabel!

    // MARK: - Sort Option
    enum SortOption: String {
        case distance = "거리순"
        case rating = "평점순"
    }

    // MARK: - Properties
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    let realm = try! Realm()
    let appid = Bundle.main.apiKey

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    /// 검색어로 서버에 재질의해서 받아온 가게 정보들의 배열
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

    var sortOption: SortOption = .distance

    /// 검색어 재질의용 디바운스 타이머 (입력 도중 매 글자마다 요청이 나가는 것을 방지)
    private var searchDebounceTimer: Timer?
    /// 서버에 마지막으로 보낸 검색어
    private var lastSearchKeyword: String = ""
    /// 검색 결과 페이지네이션 상태
    private var searchPage: Int = 1
    private var isSearchEnd: Bool = false
    private var isSearchLoading: Bool = false

    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // 외형 설정은 권한과 무관하게 항상 적용한다.
        // (전에는 아래 권한 블록 안에 있어서, 권한을 거부하면 배경색·폰트가 통째로 빠졌다)
        setInitData()
        setLocationManager()
        setupNavigationbar()
        setupSearchController()
        setupTableView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(regionDidChange),
            name: RegionStore.didChangeNotification,
            object: nil
        )

        let status = locationManager.authorizationStatus

        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    /// 홈 탭에서 지역을 바꾸면 검색 탭의 기본 목록도 같은 지역으로 다시 불러온다
    @objc func regionDidChange() {
        guard let location = RegionStore.shared.selectedLocation else { return }

        currentLocation = location
        getRamenData(url: url, currentLocation: (location.coordinate.latitude, location.coordinate.longitude))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        deleteNoDataItem()
    }

    // MARK: - Set Up
    func setInitData() {
        // 다른 탭과 같은 배경을 쓴다 (전에는 이 화면만 흰 배경이라 탭을 옮길 때 배경이 튀었다)
        view.backgroundColor = CustomColor.ground
        searchTableView.backgroundColor = CustomColor.ground

        introduceLabel.font = AppFont.title(14)
        introduceLabel.textColor = CustomColor.ink
        introduceLabel.backgroundColor = .clear
        introduceLabel.text = "현재 지역을 중심으로 가게를 검색합니다."
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
        navigationController?.navigationBar.backgroundColor = CustomColor.ground
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: AppFont.title(20)]

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "map"), style: .plain, target: self, action: #selector(mapButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), menu: makeSortMenu())
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

    // MARK: - Sort
    func makeSortMenu() -> UIMenu {
        let actions = [SortOption.distance, SortOption.rating].map { option in
            UIAction(title: option.rawValue, state: sortOption == option ? .on : .off) { [weak self] _ in
                self?.sortOption = option
                self?.setupNavigationbar()
                self?.applySort()
            }
        }

        return UIMenu(title: "정렬 기준", children: actions)
    }

    func applySort() {
        sortList(&defaultList)
        sortList(&searchedList)
        searchTableView.reloadData()
    }

    func sortList(_ list: inout [RamenData]) {
        switch sortOption {
        case .distance:
            list.sort { distance(to: $0) < distance(to: $1) }
        case .rating:
            list.sort { $0.rating > $1.rating }
        }
    }

    func distance(to item: RamenData) -> Double {
        guard let currentLocation = currentLocation else { return .greatestFiniteMagnitude }
        return currentLocation.distance(from: CLLocation(latitude: item.y, longitude: item.x))
    }

    // MARK: - Action
    @objc func mapButtonTapped() {
        let mapVC = MapViewController()
        mapVC.stores = isFiltered ? searchedList : defaultList
        mapVC.centerLocation = currentLocation

        setCustomBackButton(title: "가게 검색")
        navigationController?.pushViewController(mapVC, animated: true)
    }

    // MARK: - API
    func getRamenData(url: String, currentLocation: (Double, Double)) {
        defaultList.removeAll()

        let headers: HTTPHeaders = ["Authorization": appid]
        let parameters: [String: Any] = [
            "query" : "라멘",
            "x": "\(currentLocation.1)",
            "y": "\(currentLocation.0)",
            "radius": 7000,
            "size": 15,
            "page": 1
        ]

        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenStore.self) { [weak self] response in
            guard let self = self else { return }

            switch response.result {
            case .success(let data):
                for ramen in data.documents {
                    self.defaultList.append(ramen.toRameDataType())
                }

                self.sortList(&self.defaultList)

                DispatchQueue.main.async {
                    self.introduceLabel.text = self.defaultList.isEmpty
                        ? "이 지역에는 라멘 가게가 없습니다."
                        : "현재 지역을 중심으로 가게를 검색합니다."
                    self.searchTableView.reloadData()
                }

            case .failure(let error):
                print("가게 목록 조회 실패: \(error)")

                DispatchQueue.main.async {
                    self.introduceLabel.text = "가게 정보를 불러오지 못했습니다. 연결을 확인해 주세요."
                    self.introduceLabel.textColor = CustomColor.inkSoft
                    self.searchTableView.reloadData()
                }
            }
        }
    }

    /// 검색어를 기반으로 서버에 재검색한다 (로컬에 이미 받아둔 15건 안에서만 찾던 방식 대신, 검색어로 카카오 API에 직접 재질의)
    func searchRamenData(keyword: String, page: Int) {
        guard let currentLocation = currentLocation, !isSearchLoading else { return }

        isSearchLoading = true

        let headers: HTTPHeaders = ["Authorization": appid]
        let parameters: [String: Any] = [
            "query": "라멘 \(keyword)",
            "x": "\(currentLocation.coordinate.longitude)",
            "y": "\(currentLocation.coordinate.latitude)",
            "radius": 20000,
            "size": 15,
            "page": page
        ]

        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenStore.self) { [weak self] response in
            guard let self = self else { return }
            self.isSearchLoading = false

            guard keyword == self.lastSearchKeyword else { return }

            switch response.result {
            case .success(let data):
                if page == 1 {
                    self.searchedList.removeAll()
                }

                for ramen in data.documents {
                    self.searchedList.append(ramen.toRameDataType())
                }

                self.isSearchEnd = data.meta?.isEnd ?? true
                self.searchPage = page
                self.sortList(&self.searchedList)

                DispatchQueue.main.async {
                    self.updateIntroduceLabel(resultCount: self.searchedList.count)
                    self.searchTableView.reloadData()
                }

            case .failure(let error):
                print("검색 실패: \(error)")

                DispatchQueue.main.async {
                    self.introduceLabel.text = "검색하지 못했습니다. 연결을 확인해 주세요."
                    self.introduceLabel.textColor = CustomColor.inkSoft
                }
            }
        }
    }

    func updateIntroduceLabel(resultCount: Int) {
        if resultCount == 0 {
            introduceLabel.text = "검색 결과가 없습니다. 다른 이름으로 찾아보세요."
            introduceLabel.textColor = CustomColor.inkSoft
        } else {
            introduceLabel.text = "검색 결과 \(resultCount)개"
            introduceLabel.textColor = CustomColor.ink
        }
    }

    // MARK: - ETC
    /// 평가가 모두 안되어 있는 아이템 삭제
    func deleteNoDataItem() {
        let shouldDeleteItems = realm.objects(RamenData.self).filter { $0.hasNoUserData }

        guard !shouldDeleteItems.isEmpty else { return }

        do {
            try realm.write {
                realm.delete(shouldDeleteItems)
            }
        } catch {
            print("정리 대상 삭제 실패: \(error)")
        }
    }
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }

        if text.isEmpty {
            introduceLabel.text = "현재 지역을 중심으로 가게를 검색합니다."
            introduceLabel.textColor = CustomColor.ink
            searchDebounceTimer?.invalidate()
            searchTableView.reloadData()
            return
        }

        lastSearchKeyword = text
        searchPage = 1
        isSearchEnd = false

        searchDebounceTimer?.invalidate()
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] _ in
            self?.searchRamenData(keyword: text, page: 1)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltered ? searchedList.count : defaultList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchTableView.dequeueReusableCell(withIdentifier: "SearchViewCell", for: indexPath) as? SearchViewCell else { return UITableViewCell() }

        let storeName = isFiltered ? searchedList[indexPath.row].storeName : defaultList[indexPath.row].storeName
        cell.searchResultLabel?.text = storeName
        cell.searchResultLabel?.font = AppFont.title(15)
        cell.searchResultLabel?.textColor = CustomColor.ink
        cell.backgroundColor = CustomColor.surface

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 검색 결과 마지막 셀에 도달하면 다음 페이지를 이어서 불러온다
        guard isFiltered, !isSearchEnd, !isSearchLoading else { return }
        guard indexPath.row == searchedList.count - 1 else { return }

        searchRamenData(keyword: lastSearchKeyword, page: searchPage + 1)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }

        let list = isFiltered ? searchedList : defaultList
        let selected = list[indexPath.row]

        let realmList = realm.objects(RamenData.self).where {
            $0.storeName == selected.storeName
            && $0.x == selected.x
            && $0.y == selected.y
        }

        if let selectedRamen = realmList.first {
            if isFiltered { detailVC.viewType = .search }
            detailVC.selectedRamen = selectedRamen
        } else {
            if isFiltered { detailVC.viewType = .search }
            detailVC.selectedRamen = selected
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
            let isFirstFix = currentLocation == nil
            currentLocation = location

            guard isFirstFix else { return }
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            getRamenData(url: url, currentLocation: (lat, long))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
