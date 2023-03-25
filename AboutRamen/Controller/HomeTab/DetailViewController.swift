import UIKit
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
    
    // MARK: - Properties
    let realm = try! Realm()
    let imageUrl: String = "https://dapi.kakao.com/v2/search/image"
    let defaultImage: UIImage = CustomImage.ramen ?? UIImage(systemName: "fork.knife")!
    let appid = Bundle.main.apiKey
    var index: Int = 0
    var searchIndex: Int = 0
    var information = List<Information>()
    var reviewState: ReviewState = .yet
    var goodPressed: Bool = false
    var myRamenPressed: Bool = false
    var store: String = ""
    var location: (long: Double, lat: Double) = (0, 0)
    var storeRating: Double = 0
    var distance: String?
    /// DetailVC에서 보여줄 두 개의 이미지 URL을 담는 배열
    var existImageUrlList: [String] = []
    var isButtonClicked: Bool = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpBorder()
        setUpBackgroundColor()
        setUpLableText()
        setUpTabImageView()
        getRamenImages()
        setPressedValue()
        starRatingView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        setPressedValue()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        guard isButtonClicked else { return }
        guard let rating = ratingLabel.text else { return }
        guard let address = addressLabel.text else { return }
        
        let goodObject = realm.objects(GoodListData.self).where {
            $0.storeName == store
            && $0.x == location.long
            && $0.y == location.lat
        }
        
        let myRating = (rating as NSString).doubleValue
        storeRating = myRating
        
        let goodData = GoodListData(storeName: store, addressName: address, x: location.0, y: location.1, rating: storeRating, isGoodPressed: goodPressed)
        
        if goodPressed {
            if goodObject.isEmpty {
                try! realm.write {
                    realm.add(goodData)
                }
            } else {
                for item in goodObject {
                    if item.rating != storeRating {
                        if let update = goodObject.filter(NSPredicate(format: "storeName = %@", store)).first {
                            try! realm.write {
                                update.rating = storeRating
                            }
                        }
                    }
                }
            }
        } else {
            if let firstItem = goodObject.first {
                try! realm.write {
                    realm.delete(firstItem)
                }
            }
        }
    }
    
    @IBAction func urlButton(_ sender: UIButton) {
        let info = Array(information)
        if let url = URL(string: info[index].place_url) {
            UIApplication.shared.open(url)
        }
    }
    
    func setPressedValue() {
        if goodPressed {
            goodLabel.text = "좋아요 취소"
            goodImageView.image = CustomImage.thumbsUpBlack
            isButtonClicked = true
        } else {
            goodLabel.text = "좋아요"
            goodImageView.image = CustomImage.thumbsUpWhite
            isButtonClicked = false
        }
        
        if myRamenPressed {
            myListLabel.text = "추가하기 취소"
            myListAddImageView.image = CustomImage.myListBlack
        } else {
            myListLabel.text = "추가하기"
            myListAddImageView.image = CustomImage.myListWhite
        }
    }
    
    func getRamenImages() {
        existImageUrlList = []
        let headers: HTTPHeaders = ["Authorization": appid]
        let params: [String: Any] = ["query": information[index].place_name]
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
                    self.pictureImageViewOne.kf.setImage(with: firstUrl, placeholder: self.defaultImage)
                } else {
                    self.pictureImageViewOne.image = self.defaultImage
                }
                
                if let secondUrl = secondUrl {
                    self.pictureImageViewTwo.kf.setImage(with: secondUrl, placeholder: self.defaultImage)
                } else {
                    self.pictureImageViewTwo.image = self.defaultImage
                }
            }
        }
    }
    
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
        let info = Array(information)
        let selectedInfo = info[index]
        let goodList = realm.objects(GoodListData.self)
        
        storeLabel.font = .boldSystemFont(ofSize: 35)
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
        if goodPressed {
            goodPressed = false
            goodLabel.text = "좋아요"
            goodImageView.image = CustomImage.thumbsUpWhite
        } else {
            goodPressed = true
            goodLabel.text = "좋아요 취소"
            goodImageView.image = CustomImage.thumbsUpBlack
        }
        
        isButtonClicked = true
    }
    
    @objc func reviewMark() {
        if reviewState == .yet {
            guard let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else { return }
            
            reviewVC.delegate = self
            reviewVC.storeName = information[index].place_name
            reviewVC.addressName = information[index].road_address_name
            
            let backButton = UIBarButtonItem(title: "가게 정보", style: .plain, target: self, action: nil)
            let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            
            self.navigationItem.backBarButtonItem = backButton
            self.navigationItem.backBarButtonItem?.tintColor = .black
            backButton.setTitleTextAttributes(attributes, for: .normal)
            
            navigationController?.pushViewController(reviewVC, animated: true)
        }
    }
    
    @objc func addMyListMark() {
        guard let storeName = storeLabel.text else { return }
        
        let myListObject = realm.objects(MyRamenListData.self).where {
            $0.storeName == storeName
            && $0.x == location.long
            && $0.y == location.lat
        }.first
        
        if myRamenPressed {
            myRamenPressed = false
            myListLabel.text = "추가하기"
            myListAddImageView.image = CustomImage.myListWhite
            guard let myListObject = myListObject else { return }
            
            try! realm.write {
                realm.delete(myListObject)
            }
        } else {
            myRamenPressed = true
            myListLabel.text = "추가하기 취소"
            
            myListAddImageView.image = CustomImage.myListBlack
            
            guard let address = addressLabel.text else { return }
            
            let myRamenData = MyRamenListData(storeName: store, address: address, x: location.long, y: location.lat, myRamenPressed: myRamenPressed)
            
            try! realm.write {
                realm.add(myRamenData)
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
    }
}
