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

/// 홈 화면
class HomeViewController: UIViewController {
    // MARK: - Sort Option
    enum SortOption: String {
        case distance = "거리순"
        case rating = "평점순"
    }

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
    /// 라멘집 이미지 URL. ramenList와 같은 길이를 유지하며, 사진이 없는 가게는 nil로 남는다
    var imageUrlList: [String?] = []
    var storeNames: [String] = []
    var distance: String?

    var regionLocation: CLLocation?
    var regionData: RegionInformation?
    var sortOption: SortOption = .distance {
        didSet { invalidateSortCache() }
    }

    /// 정렬 결과 캐시 (cellForItemAt마다 전체 정렬이 도는 것을 막는다)
    private var cachedSortedIndices: [Int]?

    /// 네트워크 요청 진행 여부
    private var isLoading: Bool = false {
        didSet { updateLoadingIndicator() }
    }

    /// 로딩·빈 상태·에러를 한곳에서 알려주는 뷰 (코드로 생성해 컬렉션뷰 위에 얹는다)
    private let statusLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    /// GPS 위치를 우선 사용했는지 여부 (지역선택은 GPS를 못 받거나 사용자가 직접 고를 때의 보조 수단)
    private var isUsingLiveLocation: Bool = false
    /// 최초 위치 확정(GPS 응답 또는 타임아웃에 의한 지역 기본값 사용)이 끝났는지 여부
    private var hasResolvedInitialLocation: Bool = false
    /// GPS 응답을 기다리다 지역 기본값으로 넘어가기까지의 유예 시간
    private var initialLocationFallbackTimer: Timer?

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        regionData = RegionStore.shared.information
        regionLocation = RegionStore.shared.defaultLocation

        /// - NOTE: Realm 위치 찾을 때 사용
        // print(">>> location: \(realm.configuration.fileURL)")
        setLocationManager()
        setUpCollectionView()
        setupNavigationbar()
        setUpStatusViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        deleteNoDataItem()
        // 상세 화면에서 별점이 바뀌었을 수 있으므로 평점순 정렬 결과를 다시 계산한다
        invalidateSortCache()
        collectionView.reloadData()
    }
    
    // MARK: - Set Up
    func setInitData() {
        view.backgroundColor = CustomColor.ground

        if isUsingLiveLocation {
            myLocationLabel.text = "현재 위치 주변"
        } else if let regionData = regionData {
            myLocationLabel.text = "\(regionData.region[0].city) \(regionData.region[0].local[0].gu)"
        }

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
        navigationController?.navigationBar.backgroundColor = CustomColor.ground

        let attributes = [NSAttributedString.Key.font: AppFont.barButton]
        regionChangeButton.setTitleTextAttributes(attributes, for: .normal)

        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.font: AppFont.navigationTitle]
        }

        // 폰트 파일명은 Recipekorea.ttf. 대문자 K로 적으면 nil이 되어 조용히 시스템 폰트로 떨어진다
        myLocationLabel.font = AppFont.title(17)
        myLocationLabel.textColor = CustomColor.ink

        let mapButton = UIBarButtonItem(image: UIImage(systemName: "map"), style: .plain, target: self, action: #selector(mapButtonTapped))
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), menu: makeSortMenu())
        navigationItem.leftBarButtonItems = [mapButton, sortButton]
    }

    /// 로딩 스피너와 상태 문구를 컬렉션뷰 중앙에 얹는다
    func setUpStatusViews() {
        statusLabel.font = AppFont.caption
        statusLabel.textColor = CustomColor.inkSoft
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.isHidden = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = CustomColor.inkSoft
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(statusLabel)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),

            loadingIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }

    private func updateLoadingIndicator() {
        if isLoading {
            statusLabel.isHidden = true
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }

    /// 결과가 없거나 요청이 실패했을 때 무엇 때문인지 구분해서 알려준다
    private func updateStatusView(error: Error?) {
        let isEmpty = (ramenList?.isEmpty ?? true)

        if let error = error {
            // 연결 자체가 안 되는 경우와 서버가 응답을 준 경우를 구분해서 알린다
            let isConnectivityError: Bool

            if let afError = error.asAFError, case .sessionTaskFailed = afError {
                isConnectivityError = true
            } else {
                isConnectivityError = false
            }

            statusLabel.text = isConnectivityError
                ? "네트워크에 연결할 수 없습니다.\n연결 상태를 확인해 주세요."
                : "가게 정보를 불러오지 못했습니다.\n잠시 후 다시 시도해 주세요."
            statusLabel.isHidden = false
        } else if isEmpty {
            statusLabel.text = "이 지역에는 라멘 가게가 없습니다.\n지역을 바꿔서 찾아보세요."
            statusLabel.isHidden = false
        } else {
            statusLabel.isHidden = true
        }
    }

    // MARK: - Sort
    func makeSortMenu() -> UIMenu {
        let actions = [SortOption.distance, SortOption.rating].map { option in
            UIAction(title: option.rawValue, state: sortOption == option ? .on : .off) { [weak self] _ in
                self?.sortOption = option
                self?.setupNavigationbar()
                self?.collectionView.reloadData()
            }
        }

        return UIMenu(title: "정렬 기준", children: actions)
    }

    /// 정렬 결과를 다시 계산하도록 캐시를 비운다 (목록 갱신·정렬 기준 변경 시)
    func invalidateSortCache() {
        cachedSortedIndices = nil
    }

    /// 현재 정렬 기준에 맞춰 ramenList를 재배열한 인덱스 순서를 반환한다.
    /// 셀마다 호출되므로 결과를 캐시해 전체 정렬이 반복되지 않게 한다.
    func sortedIndices() -> [Int] {
        if let cached = cachedSortedIndices { return cached }

        guard let ramenList = ramenList else { return [] }
        let indices = Array(0..<ramenList.count)
        let sorted: [Int]

        switch sortOption {
        case .distance:
            // 거리 계산을 미리 한 번씩만 해두고 그 값으로 정렬한다
            let distances = indices.map { distanceValue(ramenList[$0]) }
            sorted = indices.sorted { distances[$0] < distances[$1] }
        case .rating:
            let ratings = indices.map { ratingValue(ramenList[$0]) }
            sorted = indices.sorted { ratings[$0] > ratings[$1] }
        }

        cachedSortedIndices = sorted
        return sorted
    }

    func distanceValue(_ item: Information) -> Double {
        guard let currentLocation = currentLocation, let x = Double(item.x), let y = Double(item.y) else { return .greatestFiniteMagnitude }
        return currentLocation.distance(from: CLLocation(latitude: y, longitude: x))
    }

    func ratingValue(_ item: Information) -> Double {
        let goodList = realm.objects(RamenData.self)
        let matched = goodList.filter {
            $0.x == (Double(item.x) ?? 0) && $0.y == (Double(item.y) ?? 0)
        }

        return matched.first?.rating ?? 0
    }
    
    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = CustomColor.ground
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
        
        isLoading = true

        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenStore.self) { [weak self] response in
            guard let self = self else { return }

            switch response.result {
            case .success(let data):
                self.ramenList = data.documents
                data.documents.forEach { self.storeNames.append($0.place_name) }
                self.invalidateSortCache()

                DispatchQueue.main.async {
                    // 이미지가 도착하기 전에도 가게 이름/거리/별점은 먼저 보여준다
                    self.collectionView.reloadData()
                    self.getRamenImages()
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.updateStatusView(error: error)
                }
            }
        }
    }

    func getRamenImages() {
        guard let ramenList = ramenList else {
            isLoading = false
            updateStatusView(error: nil)
            return
        }

        // 응답 순서가 요청 순서와 다르기 때문에 append가 아니라 인덱스로 채워 넣는다.
        // (append 방식은 이미지가 없는 가게에서 한 칸씩 밀려 가게-사진 짝이 어긋난다)
        imageUrlList = Array(repeating: nil, count: ramenList.count)

        let headers: HTTPHeaders = ["Authorization": appid]
        let group = DispatchGroup()

        for (index, name) in storeNames.enumerated() {
            group.enter()

            let params: [String: Any] = ["query": name]
            AF.request(imageUrl, method: .get, parameters: params, headers: headers).responseDecodable(of: RamenImage.self) { [weak self] response in
                defer { group.leave() }
                guard let self = self, index < self.imageUrlList.count else { return }

                self.imageUrlList[index] = response.value?.documents.first?.image_url
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            self.updateStatusView(error: nil)
            self.collectionView.reloadData()
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

    @objc func mapButtonTapped() {
        guard let ramenList = ramenList else { return }

        let mapVC = MapViewController()
        mapVC.stores = ramenList.map { $0.toRameDataType() }
        mapVC.centerLocation = currentLocation ?? regionLocation

        setCustomBackButton(title: "홈")
        navigationController?.pushViewController(mapVC, animated: true)
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

        let originalIndex = sortedIndices()[indexPath.row]
        let ramenData = ramenList[originalIndex].toRameDataType()

        cell.cellConfigure()

        // 거리
        let targetLocation = CLLocation(latitude: ramenData.y, longitude: ramenData.x)
        cell.distanceLabel.text = getDistance(from: currentLocation, to: targetLocation)

        // 별점. 매겨진 값이 없으면 "별점 없음" 문구 대신 배지를 숨긴다 (배지 폭이 들쭉날쭉해지는 것 방지)
        let rated = realm.objects(RamenData.self).filter {
            $0.x == ramenData.x && $0.y == ramenData.y
        }.first

        cell.setRating(rated?.rating)

        // 이미지. imageUrlList는 ramenList와 길이가 같고, 사진이 없는 가게는 nil이다
        if originalIndex < imageUrlList.count,
           let urlString = imageUrlList[originalIndex],
           let url = URL(string: urlString) {
            cell.ramenImageView.kf.setImage(with: url, placeholder: CustomImage.ramen)
        } else {
            cell.ramenImageView.kf.cancelDownloadTask()
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

        let originalIndex = sortedIndices()[indexPath.row]
        let ramen = ramenList[originalIndex]
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
        let selected = CLLocation(latitude: location.lat, longitude: location.long)
        regionLocation = selected

        // 사용자가 지역을 직접 골랐으므로 더 이상 GPS 기준이 아니다
        isUsingLiveLocation = false
        invalidateSortCache()

        // 검색 탭도 같은 지역을 보도록 공유 저장소에 반영한다
        RegionStore.shared.update(location: selected, title: myLocationLabel.text ?? "")

        getRamenData(url: url, currentLocation: selected)
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocation = location
        // 거리순 정렬은 현재 위치에 의존하므로 위치가 바뀌면 다시 계산한다
        invalidateSortCache()

        guard !hasResolvedInitialLocation else { return }
        hasResolvedInitialLocation = true
        initialLocationFallbackTimer?.invalidate()

        // GPS 위치를 우선 사용하고, 지역선택(RegionPicker)은 GPS를 못 받았을 때의 보조 수단으로만 사용한다
        isUsingLiveLocation = true
        regionLocation = location
        setInitData()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 확인 실패: \(error)")
        useRegionDefaultIfNeeded()
    }

    /// iOS 14부터의 권한 변경 콜백 (구 didChangeAuthorization은 deprecated)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            scheduleInitialLocationFallback()
        case .notDetermined:
            getLocationUsagePermission()
        case .restricted, .denied:
            useRegionDefaultIfNeeded()
        @unknown default:
            useRegionDefaultIfNeeded()
        }
    }

    /// GPS 응답을 일정 시간 기다렸다가 안 오면 지역 기본값(RegionInformation.json)으로 진행한다
    private func scheduleInitialLocationFallback() {
        guard !hasResolvedInitialLocation else { return }

        initialLocationFallbackTimer?.invalidate()
        initialLocationFallbackTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.useRegionDefaultIfNeeded()
        }
    }

    private func useRegionDefaultIfNeeded() {
        guard !hasResolvedInitialLocation else { return }
        hasResolvedInitialLocation = true
        isUsingLiveLocation = false
        setInitData()
    }
}

