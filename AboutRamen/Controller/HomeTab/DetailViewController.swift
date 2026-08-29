import UIKit
import CoreLocation
import Alamofire
import Kingfisher
import RealmSwift

// MARK: - Enum
enum ReviewState: String {
    case yet = "리뷰하기"
    case done = "리뷰완료"
}

// MARK: - Protocol
/// weak 참조로 잡을 수 있도록 클래스 전용 프로토콜로 제한한다
protocol ReviewCompleteProtocol: AnyObject {
    func sendReview(state: ReviewState)
}

/// 상세 화면
class DetailViewController: UIViewController {
    // MARK: - View Type
    enum ViewType: String {
        case detail = "가게 정보" // 기본 상세 화면
        case goodList = "좋아요 가게"// 좋아요 목록
        case search = "가게 검색" // 가게 검색 상세 화면
        case favoriteList = "나의 라멘 가게" // 나의 라멘 가게
    }
    
    // MARK: - UI
    @IBOutlet var informationView: UIView!
    @IBOutlet var addressView: UIView!
    @IBOutlet var numberView: UIView!
    @IBOutlet var urlView: UIView!
    @IBOutlet var pictureView: UIView!
    @IBOutlet var buttonsView: UIView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var storeLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var urlButton: UIButton!
    @IBOutlet var pictureImageViewOne: UIImageView!
    @IBOutlet var pictureImageViewTwo: UIImageView!
    
    @IBOutlet var goodImageView: UIImageView!
    @IBOutlet var reviewImageView: UIImageView!
    @IBOutlet var myListAddImageView: UIImageView!
    
    @IBOutlet var goodLabel: UILabel!
    @IBOutlet var reviewLabel: UILabel!
    @IBOutlet var myListLabel: UILabel!
    
    @IBOutlet var starRatingView: RatingView!
    
    // MARK: - Properties
    let imageUrl: String = "https://dapi.kakao.com/v2/search/image"
    let appid = Bundle.main.apiKey
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation? {
        didSet {
            guard let selectedRamen = selectedRamen else { return }
            let targetLocation = CLLocation(latitude: selectedRamen.y, longitude: selectedRamen.x)
            distanceLabel.text = getDistance(from: currentLocation, to: targetLocation)
            distanceLabel.font = AppFont.caption
        }
    }
    
    var reviewState: ReviewState = .yet
    var viewType: ViewType = .detail
    
    /// 테이블뷰에서 눌른 셀에 해당하는 데이터 (이전 화면에서 넘겨받은 데이터)
    var selectedRamen: RamenData?
    /// DetailVC에서 보여줄 두 개의 이미지 URL을 담는 배열
    var existImageUrlList: [String] = []
    /// 별점이 수정되었을 경우 true
    var newRating: Double = 0
    /// 리뷰 여부
    var isReviewed: Bool = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        starRatingView.delegate = self
        setLocationManager()
        setNavigationbar()
        setUpBorder()
        setUpBackgroundColor()
        setUpLableText()
        setUpTabImageView()
        getRamenImages()
        
        // iOS 14부터는 타입 메서드 authorizationStatus() 대신 인스턴스 프로퍼티를 쓴다
        let status = locationManager.authorizationStatus

        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }

        setInitData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initButtonState()
        setInitData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        saveData()
    }
    
    // MARK: - Set up
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setNavigationbar() {
        // 타이틀 설정
        navigationItem.title = viewType.rawValue
        navigationController?.navigationBar.backgroundColor = CustomColor.ground
    }

    /// 진한 검정 테두리 대신 흰 카드 + 헤어라인으로 영역을 구분한다
    func setUpBorder() {
        [addressView, numberView, urlView, buttonsView].forEach { card in
            guard let card = card else { return }

            card.backgroundColor = CustomColor.surface
            card.layer.cornerRadius = 14
            card.layer.borderWidth = 1
            card.layer.borderColor = CustomColor.hairline.cgColor

            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.06
            card.layer.shadowRadius = 6
            card.layer.shadowOffset = CGSize(width: 0, height: 3)
            card.layer.masksToBounds = false
        }

        ratingLabel.backgroundColor = CustomColor.accent
        ratingLabel.textColor = .white
        ratingLabel.textAlignment = .center
        ratingLabel.clipsToBounds = true
        ratingLabel.layer.cornerRadius = 12

        urlButton.layer.cornerRadius = 12

        // 사진 사이의 검은 분할선 대신 모서리를 둥글려 간격으로 구분한다
        [pictureImageViewOne, pictureImageViewTwo].forEach { imageView in
            imageView?.layer.cornerRadius = 12
            imageView?.clipsToBounds = true
            imageView?.contentMode = .scaleAspectFill
        }
    }

    func setUpBackgroundColor() {
        view.backgroundColor = CustomColor.ground
        pictureView.backgroundColor = .clear

        [addressLabel, numberLabel].forEach {
            $0?.backgroundColor = .clear
            $0?.textColor = CustomColor.ink
        }

        urlButton.backgroundColor = CustomColor.surface
        storeLabel.textColor = CustomColor.ink
        distanceLabel.textColor = CustomColor.inkSoft
    }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)

        // cgColor는 다이나믹 컬러를 자동으로 따라가지 않는다
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previous) else { return }

        [addressView, numberView, urlView, buttonsView].forEach {
            $0?.layer.borderColor = CustomColor.hairline.cgColor
        }
    }
    
    func setUpTabImageView() {
        addTabGesture(target: goodImageView, action: #selector(goodMark), label: "좋아요")
        addTabGesture(target: reviewImageView, action: #selector(reviewMark), label: "리뷰 쓰기")
        addTabGesture(target: myListAddImageView, action: #selector(addMyListMark), label: "나의 라멘 가게에 추가")
    }

    /// - NOTE: 스토리보드 아웃렛이 UIImageView라 UIButton으로는 교체하지 못했다.
    ///   대신 VoiceOver가 버튼으로 읽도록 접근성 정보를 붙이고, 탭 피드백을 준다.
    func addTabGesture(target: UIImageView, action: Selector, label: String) {
        let addTabGesture = UITapGestureRecognizer(target: self, action: action)
        target.addGestureRecognizer(addTabGesture)
        target.isUserInteractionEnabled = true

        target.isAccessibilityElement = true
        target.accessibilityTraits = .button
        target.accessibilityLabel = label
    }

    /// 토글이 눌렸다는 것을 촉각으로도 알린다
    private func playToggleFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Action
    @IBAction func urlButton(_ sender: UIButton) {
        var urlString = ""
        
        if let selectedRamen = selectedRamen {
            urlString = selectedRamen.url
        }
        
        if !urlString.isEmpty, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Init Data
    func initButtonState() {
        guard let selectedRamen = selectedRamen else { return }
        goodLabel.text = selectedRamen.isGood ? "좋아요 취소" : "좋아요"
        goodImageView.image = selectedRamen.isGood ? CustomImage.thumbsUpBlack : CustomImage.thumbsUpWhite

        myListLabel.text = selectedRamen.isFavorite ? "추가하기 취소" : "추가하기"
        myListAddImageView.image = selectedRamen.isFavorite ? CustomImage.myListBlack : CustomImage.myListWhite

        // 접근성 최소 권장(11pt)에 못 미치던 9pt를 12pt로 올린다
        [goodLabel, myListLabel, reviewLabel].forEach {
            $0?.font = AppFont.actionLabel
            $0?.textColor = CustomColor.ink
        }
    }

    func setInitData() {
        guard let selectedRamen = selectedRamen else { return }

        reviewState = selectedRamen.isReviewed ? .done : .yet
        reviewImageView.image = reviewState == .yet ? CustomImage.reviewWhite : CustomImage.reviewBlack
        reviewLabel.text = reviewState.rawValue
        reviewLabel.font = AppFont.actionLabel
        isReviewed = selectedRamen.isReviewed
    }
    
    func setUpLableText() {
        guard let selectedRamen = selectedRamen else { return }
        
        storeLabel.font = AppFont.display(28)
        storeLabel.text = selectedRamen.storeName
        ratingLabel.text = selectedRamen.rating > 0 ? String(format: "%.1f", selectedRamen.rating) : "-"
        ratingLabel.font = AppFont.title(15)
        starRatingView.rating = selectedRamen.rating
        newRating = selectedRamen.rating

        let attributes = [NSAttributedString.Key.font: AppFont.actionLabel]
        let text = NSAttributedString(string: "가게 위치 정보 없음", attributes: attributes)

        if selectedRamen.url.isEmpty {
            urlButton.setAttributedTitle(text, for: .normal)
        }

        addressLabel.text = selectedRamen.addressName.isEmpty ? "주소 정보 없음" : selectedRamen.addressName
        addressLabel.font = AppFont.body(15)
        numberLabel.text = selectedRamen.phone.isEmpty ? "전화번호 정보 없음" : selectedRamen.phone
        numberLabel.font = AppFont.body(15)
    }
    
    // MARK: - API
    func getRamenImages() {
        
        guard let selectedRamen = selectedRamen else { return }
        existImageUrlList = []
        
        let headers: HTTPHeaders = ["Authorization": appid]
        let params: [String: Any] = ["query": selectedRamen.storeName]
        
        AF.request(imageUrl, method: .get, parameters: params, headers: headers).responseDecodable(of: RamenImage.self) { [weak self] response in
            guard let self = self else { return }

            switch response.result {
            case .success(let dataImage):
                // 최대 두 장까지만 보여준다
                self.existImageUrlList = dataImage.documents.prefix(2).map { $0.image_url }

            case .failure(let error):
                // 실패해도 기본 이미지로 채워지므로 화면이 비지는 않는다
                print("가게 이미지 조회 실패: \(error)")
            }

            DispatchQueue.main.async {
                var firstUrl: URL?
                var secondUrl: URL?
                
                if self.existImageUrlList.count == 2 {
                    firstUrl = URL(string: self.existImageUrlList[0])
                    secondUrl = URL(string: self.existImageUrlList[1])
                } else if self.existImageUrlList.count == 1 {
                    firstUrl = URL(string: self.existImageUrlList[0])
                }
                
                if let firstUrl = firstUrl {
                    self.pictureImageViewOne.kf.setImage(with: firstUrl, placeholder: CustomImage.ramen)
                } else {
                    self.pictureImageViewOne.image = CustomImage.ramen
                }
                
                if let secondUrl = secondUrl {
                    self.pictureImageViewTwo.kf.setImage(with: secondUrl, placeholder: CustomImage.ramen)
                } else {
                    self.pictureImageViewTwo.image = CustomImage.ramen
                }
            }
        }
    }
}

// MARK: Objectb Action
extension DetailViewController {
    /// 저장에 실패하면 사용자에게 알린다. 실제 쓰기는 RamenStorage가 담당한다.
    @discardableResult
    private func writeToRealm(_ block: (Realm) -> Void) -> Bool {
        let didWrite = RamenStorage.write(block)

        if !didWrite {
            showAlert(title: "저장하지 못했습니다", message: "잠시 후 다시 시도해 주세요.", alertStyle: .oneButton)
        }

        return didWrite
    }

    /// '좋아요' 버튼 액션
    @objc func goodMark() {
        guard let selectedRamen = selectedRamen else { return }

        guard writeToRealm({ _ in selectedRamen.isGood.toggle() }) else { return }
        playToggleFeedback()

        if selectedRamen.isGood {
            goodLabel.text = "좋아요 취소"
            goodImageView.image = CustomImage.thumbsUpBlack
        } else {
            goodLabel.text = "좋아요"
            goodImageView.image = CustomImage.thumbsUpWhite
        }
    }

    /// '리뷰 추가' 버튼 액션
    @objc func reviewMark() {
        guard let selectedRamen = selectedRamen else { return }

        let saved = RamenStorage.allStores?.where {
            $0.storeName == selectedRamen.storeName
            && $0.x == selectedRamen.x
            && $0.y == selectedRamen.y
        }

        let alreadySaved = saved?.filter(NSPredicate(format: "_id == %@", selectedRamen._id)).first != nil

        if !alreadySaved {
            guard writeToRealm({ realm in realm.add(selectedRamen) }) else { return }
        }

        guard let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else { return }

        reviewVC.delegate = self
        reviewVC.selectedRamen = selectedRamen
        setCustomBackButton(title: "가게 정보")
        navigationController?.pushViewController(reviewVC, animated: true)
    }

    /// '나의 라면 가게' 버튼 액션
    @objc func addMyListMark() {
        guard let selectedRamen = selectedRamen else { return }

        guard writeToRealm({ _ in selectedRamen.isFavorite.toggle() }) else { return }
        playToggleFeedback()

        if selectedRamen.isFavorite {
            myListLabel.text = "추가하기 취소"
            myListAddImageView.image = CustomImage.myListBlack
        } else {
            myListLabel.text = "추가하기"
            myListAddImageView.image = CustomImage.myListWhite
        }
    }

    func saveData() {
        guard let selectedRamen = selectedRamen else { return }

        // 별점을 매기지 않았고 좋아요·리뷰·찜도 없다면 저장할 것이 없다
        // (빈 레코드를 만들어두면 다음 화면에서 정리 대상으로 잡혔다가 지워지는 왕복이 생긴다)
        guard newRating > 0 || selectedRamen.isGood || selectedRamen.isReviewed || selectedRamen.isFavorite else { return }

        let rating = newRating

        writeToRealm { realm in
            selectedRamen.rating = rating
            realm.add(selectedRamen, update: .modified)
        }
    }
}

// MARK: - ReviewCompleteProtocol
extension DetailViewController: ReviewCompleteProtocol {
    func sendReview(state: ReviewState) {
        reviewState = state
    }
}

// MARK: - RatingViewDelegate
extension DetailViewController: RatingViewDelegate {
    func ratingView(_ ratingView: RatingView, isUpdating rating: Double) {
        ratingLabel.text = String(rating)
        newRating = rating
    }
}

// MARK: - CLLocationManagerDelegate
extension DetailViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
