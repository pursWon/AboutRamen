import UIKit
import Alamofire
import Kingfisher
import RealmSwift

// TODO: Review 데이터 관리
// TODO: 별점 정보 저장

// MARK: - Enum
enum ReviewState: String {
    case yet = "리뷰하기"
    case done = "리뷰완료"
}

// MARK: - Protocol
protocol ReviewCompleteProtocol {
    func sendReview(state: ReviewState)
}

class DetailViewController: UIViewController {
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

    // TODO: case 중 필요없는게 있는지 체크
    enum ViewType: String {
        case detail = "가게 정보" // 기본 상세 화면
        case goodList = "좋아요 가게"// 좋아요 목록
        case search = "가게 검색" // 가게 검색 상세 화면
        case favoriteList = "나의 라면 가게" // 나의 라면 가게
    }

    // MARK: - Properties
    let realm = try! Realm()
    let imageUrl: String = "https://dapi.kakao.com/v2/search/image"
    let appid = Bundle.main.apiKey
    let loadingView = UIActivityIndicatorView(style: .medium)

    var searchIndex: Int = 0
    var reviewState: ReviewState = .yet
    var viewType: ViewType = .detail
    /// DetailVC에서 보여줄 두 개의 이미지 URL을 담는 배열
    var existImageUrlList: [String] = []
    /// 별점이 수정되었을 경우 true
    var newRating: Double = 0
    /// 좋아요, 추가하기 버튼이 놀렸을 경우 true
    var isButtonClicked: Bool = false
    /// 테이블뷰에서 눌른 셀에 해당하는 데이터 (이전 화면에서 넘겨받은 데이터)
    var selectedRamen: RamenData?

    /// 현재 위치로 부터 선택한 가게까지의 거리
    var distance: String = ""
    var isReviewed: Bool = false

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationbar()
        setUpBorder()
        setUpBackgroundColor()
        setUpLableText()
        setUpTabImageView()
        getRamenImages()
        initButtonState()
        starRatingView.delegate = self

        if let selectedRamen = selectedRamen {
            print(">>> id: \(selectedRamen._id), name: \(selectedRamen.storeName) - rating: \(selectedRamen.rating), fav: \(selectedRamen.isFavorite), good: \(selectedRamen.isGood), review: \(selectedRamen.isReviewed)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var reviewImage: UIImage?

        switch reviewState {
        case .yet:
            reviewImage = CustomImage.reviewWhite
        case .done:
            reviewImage = CustomImage.reviewBlack
        }

        if let reviewImage = reviewImage {
            reviewImageView.image = reviewImage
        }

        reviewLabel.text = reviewState.rawValue
        initButtonState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        saveData()

        let shouldDeleteItems = realm.objects(RamenData.self).filter { !$0.isGood && !$0.isReviewed && !$0.isReviewed }

        if !shouldDeleteItems.isEmpty {
            try! realm.write {
                realm.delete(shouldDeleteItems)
            }
        }
    }


    // MARK: - Set up
    func setNavigationbar() {
        // 타이틀 설정
        navigationItem.title = viewType.rawValue
        navigationController?.navigationBar.backgroundColor = CustomColor.beige
    }

    func setUpBorder() {
        [addressView, numberView, urlView, pictureView, buttonsView, ratingLabel].forEach {
            $0!.layer.borderWidth = 2
            $0!.layer.borderColor = UIColor.black.cgColor
        }

        [buttonsView, ratingLabel, urlButton].forEach { $0.layer.cornerRadius = 10 }
        pictureImageViewOne.layer.addBorder([.right], color: .black, width: 2)
    }

    func setUpBackgroundColor() {
        [view, addressLabel, numberLabel, urlButton].forEach { $0.backgroundColor = CustomColor.beige }
    }

    func addTabGesture(target: UIImageView, action: Selector) {
        let addTabGesture = UITapGestureRecognizer(target: self, action: action)
        target.addGestureRecognizer(addTabGesture)
        target.isUserInteractionEnabled = true
    }

    func setUpTabImageView() {
        addTabGesture(target: goodImageView, action: #selector(goodMark))
        addTabGesture(target: reviewImageView, action: #selector(reviewMark))
        addTabGesture(target: myListAddImageView, action:  #selector(addMyListMark))
    }

    // MARK: - Action
    @IBAction func urlButton(_ sender: UIButton) {
        var urlString = ""

        if viewType == .notSearched {
            let info = Array(information)
            urlString = info[index].place_url
        } else {
            if let searchedData = searchedData {
                urlString = searchedData.url
            }
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
    }

    func setUpLableText() {
        guard let selectedRamen = selectedRamen else { return }

        storeLabel.font = .boldSystemFont(ofSize: 35)
        storeLabel.text = selectedRamen.storeName
        // TODO: distance 계산 해서 대입하기
        distanceLabel.text = "-- km (구해야 됨)"
        ratingLabel.text = "\(selectedRamen.rating)"
        starRatingView.rating = selectedRamen.rating
        newRating = selectedRamen.rating

        if selectedRamen.url.isEmpty {
            urlButton.setTitle("가게 위치 정보 없음", for: .normal)

        }

        addressLabel.text = selectedRamen.addressName.isEmpty ? "주소 정보 없음" : selectedRamen.addressName
        numberLabel.text = selectedRamen.phone.isEmpty ? "전화번호 정보 없음" : selectedRamen.phone
    }

    func getRamenImages() {
        guard let selectedRamen = selectedRamen else { return }
        existImageUrlList = []

        let headers: HTTPHeaders = ["Authorization": appid]
        let params: [String: Any] = ["query": selectedRamen.storeName]

        if viewType == .notSearched {
            params = ["query": information[index].place_name]
        } else {
            params = ["query": searchedData?.storeName ?? ""]
        }

        AF.request(imageUrl, method: .get, parameters: params, headers: headers).responseDecodable(of: RamenImage.self) { response in
            if let dataImage = response.value {
                if dataImage.documents.count >= 2 {
                    let firstImageUrl = dataImage.documents[0].image_url
                    let secondImageUrl = dataImage.documents[1].image_url
                    self.existImageUrlList.append(firstImageUrl)
                    self.existImageUrlList.append(secondImageUrl)
                } else if dataImage.documents.count == 1 {
                    let firstImageUrl = dataImage.documents[0].image_url
                    self.existImageUrlList.append(firstImageUrl)
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

    func setUpBorder() {
        [addressView, numberView, urlView, pictureView, buttonsView, ratingLabel].forEach {
            $0!.layer.borderWidth = 2
            $0!.layer.borderColor = UIColor.black.cgColor
        }

        [buttonsView, ratingLabel, urlButton].forEach {
            $0.layer.cornerRadius = 10
        }

        pictureImageViewOne.layer.addBorder([.right], color: .black, width: 2)
    }

    func setUpBackgroundColor() {
        [view, addressLabel, numberLabel, urlButton].forEach {
            $0.backgroundColor = CustomColor.beige
        }
    }

    func setUpLableText() {
        storeLabel.font = .boldSystemFont(ofSize: 35)

        if viewType == .notSearched {
            let info = Array(information)
            let selectedInfo = info[index]
            let goodList = realm.objects(GoodListData.self)

            storeLabel.text = selectedInfo.place_name

            if let distance = distance {
                distanceLabel.text = "\(distance)km"
            }

            for item in goodList {
                if String(item.x) == selectedInfo.x && String(item.y) == selectedInfo.y {
                    ratingLabel.text = "\(item.rating)"
                    starRatingView.rating = item.rating
                    break
                }
            }

            if info[index].place_url.isEmpty {
                urlButton.setTitle("가게 위치 정보 없음", for: .normal)
            }

            if selectedInfo.road_address_name.isEmpty {
                addressLabel.text = "주소 정보 없음"
            } else {
                addressLabel.text = selectedInfo.road_address_name
            }

            if selectedInfo.phone.isEmpty {
                numberLabel.text = "전화번호 정보 없음"
            } else {
                numberLabel.text = selectedInfo.phone
            }

            if let distance = distance {
                distanceLabel.text = "\(distance)km"
            }
        } else {
            if let info = searchedData {
                storeLabel.text = info.storeName
                ratingLabel.text = "\(info.rating)"
                starRatingView.rating = info.rating

                if info.url.isEmpty {
                    urlButton.setTitle("가게 위치 정보 없음", for: .normal)
                }

                if info.addressName.isEmpty {
                    addressLabel.text = "주소 정보 없음"
                } else {
                    addressLabel.text = info.addressName
                }

                if info.phone.isEmpty {
                    numberLabel.text = "전화번호 정보 없음 2"
                } else {
                    numberLabel.text = info.phone
                }

                if let distance = distance {
                    distanceLabel.text = "\(distance)km"
                }
            }
        }
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

        isButtonClicked = true
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

        isButtonClicked = true
    }

    func saveData() {
        guard let selectedRamen = selectedRamen else { return }

        let realmList = realm.objects(RamenData.self).where {
            $0.storeName == selectedRamen.storeName
            && $0.x == selectedRamen.x
            && $0.y == selectedRamen.y
        }

        // 기존에 존재하는 데이터면
        if let existItem = realmList.filter(NSPredicate(format: "_id == %@", selectedRamen._id)).first {
            try! realm.write {
                print(">>> good update...")
                existItem.isGood = selectedRamen.isGood
                existItem.isFavorite = selectedRamen.isFavorite
                existItem.rating = newRating
            }
        } else {
            myRamenPressed = true
            myListLabel.text = "추가하기 취소"

            myListAddImageView.image = CustomImage.myListBlack

            guard let address = addressLabel.text else { return }

            let myRamenData = MyRamenListData(storeName: store, address: address, x: location.long, y: location.lat, url: url, phone: information[index].phone, myRamenPressed: myRamenPressed
            try! realm.write {
                print(">>> good add...")
                selectedRamen.rating = newRating
                realm.add(selectedRamen)
            }
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
        print(">>> rating: \(newRating)")
    }
}

