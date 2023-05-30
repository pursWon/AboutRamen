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
protocol ReviewCompleteProtocol {
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
    let realm = try! Realm()
    let imageUrl: String = "https://dapi.kakao.com/v2/search/image"
    let appid = Bundle.main.apiKey
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation? {
        didSet {
            guard let selectedRamen = selectedRamen else { return }
            let targetLocation = CLLocation(latitude: selectedRamen.y, longitude: selectedRamen.x)
            distanceLabel.text = getDistance(from: currentLocation, to: targetLocation)
            distanceLabel.font = UIFont(name: "Recipekorea", size: 13)
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
        
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
            setInitData()
        }
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
        navigationController?.navigationBar.backgroundColor = CustomColor.beige
    }
    
    func setUpBorder() {
        [addressView, numberView, urlView, buttonsView, ratingLabel].forEach {
            $0!.layer.borderWidth = 2
            $0!.layer.borderColor = UIColor.black.cgColor
        }
        
        [buttonsView, ratingLabel, urlButton].forEach{ $0.layer.cornerRadius = 10 }
        pictureImageViewOne.layer.addBorder([.right], color: .black, width: 2)
    }
    
    func setUpBackgroundColor() {
        [view, addressLabel, numberLabel, urlButton].forEach{ $0.backgroundColor = CustomColor.beige }
    }
    
    func setUpTabImageView() {
        addTabGesture(target: goodImageView, action: #selector(goodMark))
        addTabGesture(target: reviewImageView, action: #selector(reviewMark))
        addTabGesture(target: myListAddImageView, action:  #selector(addMyListMark))
    }
    
    func addTabGesture(target: UIImageView, action: Selector) {
        let addTabGesture = UITapGestureRecognizer(target: self, action: action)
        target.addGestureRecognizer(addTabGesture)
        target.isUserInteractionEnabled = true
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
        goodLabel.font = UIFont(name: "Recipekorea", size: 9)
        goodImageView.image = selectedRamen.isGood ? CustomImage.thumbsUpBlack : CustomImage.thumbsUpWhite
        
        myListLabel.text = selectedRamen.isFavorite ? "추가하기 취소" : "추가하기"
        myListLabel.font = UIFont(name: "Recipekorea", size: 9)
        myListAddImageView.image = selectedRamen.isFavorite ? CustomImage.myListBlack : CustomImage.myListWhite
    }
    
    func setInitData() {
        guard let selectedRamen = selectedRamen else { return }
        
        reviewState = selectedRamen.isReviewed ? .done : .yet
        reviewImageView.image = reviewState == .yet ? CustomImage.reviewWhite : CustomImage.reviewBlack
        reviewLabel.text = reviewState.rawValue
        reviewLabel.font = UIFont(name: "Recipekorea", size: 9)
        isReviewed = selectedRamen.isReviewed
    }
    
    func setUpLableText() {
        guard let selectedRamen = selectedRamen else { return }
        
        storeLabel.font = UIFont(name: "BlackHanSans-Regular", size: 30)
        storeLabel.text = selectedRamen.storeName
        ratingLabel.text = "\(selectedRamen.rating)"
        starRatingView.rating = selectedRamen.rating
        newRating = selectedRamen.rating
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Recipekorea", size: 9) ?? UIFont()]
        let text = NSAttributedString(string: "가게 위치 정보 없음", attributes: attributes)
        
        if selectedRamen.url.isEmpty {
            urlButton.setAttributedTitle(text, for: .normal)
        }
        
        addressLabel.text = selectedRamen.addressName.isEmpty ? "주소 정보 없음" : selectedRamen.addressName
        addressLabel.font = UIFont(name: "S-CoreDream-4Regular", size: 15)
        numberLabel.text = selectedRamen.phone.isEmpty ? "전화번호 정보 없음" : selectedRamen.phone
        numberLabel.font = UIFont(name: "S-CoreDream-4Regular", size: 15)
    }
    
    // MARK: - API
    func getRamenImages() {
        
        guard let selectedRamen = selectedRamen else { return }
        existImageUrlList = []
        
        let headers: HTTPHeaders = ["Authorization": appid]
        let params: [String: Any] = ["query": selectedRamen.storeName]
        
        AF.request(imageUrl, method: .get, parameters: params, headers: headers).responseDecodable(of: RamenImage.self) { response in
            if let dataImage = response.value {
                
                if dataImage.documents.count >= 2 {
                    self.existImageUrlList.append(dataImage.documents[0].image_url)
                    self.existImageUrlList.append(dataImage.documents[1].image_url)
                } else if dataImage.documents.count == 1 {
                    self.existImageUrlList.append(dataImage.documents[0].image_url)
                }
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
    /// '좋아요' 버튼 액션
    @objc func goodMark() {
        guard let selectedRamen = selectedRamen else { return }
        
        try! realm.write {
            selectedRamen.isGood.toggle()
        }
        
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
        
        let realmList = realm.objects(RamenData.self).where {
            $0.storeName == selectedRamen.storeName
            && $0.x == selectedRamen.x
            && $0.y == selectedRamen.y
        }
        
        if realmList.filter(NSPredicate(format: "_id == %@", selectedRamen._id)).first == nil {
            try! realm.write {
                realm.add(selectedRamen)
            }
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
        
        try! realm.write {
            selectedRamen.isFavorite.toggle()
        }
        
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
        
        try! realm.write {
            selectedRamen.rating = newRating
            realm.add(selectedRamen)
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
