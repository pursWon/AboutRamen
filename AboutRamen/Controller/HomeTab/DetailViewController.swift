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
    @IBOutlet var storeLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var addressView: UIView!
    @IBOutlet var numberView: UIView!
    @IBOutlet var timeView: UIView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var buttonsView: UIView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var pictureView: UIView!
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
    let beige = UIColor(red: 255/255, green: 231/255, blue: 204/255, alpha: 1.0)
    let sage = UIColor(red: 225/255, green: 238/255, blue: 221/255, alpha: 1.0)
    var index: Int = 0
    var information = List<Information>()
    var searchIndex: Int = 0
    var reviewState: ReviewState = .yet
    var imageUrlList: (String?, String?)
    var goodPressed: Bool = false
    var myRamenPressed: Bool = false
    var store: String = ""
    var location: (Double, Double) = (0,0)
    var storeRating: Double = 0
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = beige
        setUpBorder()
        setUpBackgroundColor()
        setUpLableText()
        setUpTabImageView()
        getRamenImages()
        setPressedValue()
        storeLabel.font = UIFont.boldSystemFont(ofSize: 35)
        starRatingView.delegate = self
        starRatingView.contentMode = .scaleAspectFit
        
        if let storeName = storeLabel.text {
            store = storeName
        }
    }
    
    func setPressedValue() {
        if goodPressed {
            goodLabel.text = "좋아요 취소"
            goodImageView.image = UIImage(named: "ThumbsUpBlack")
        } else {
            goodLabel.text = "좋아요"
            goodImageView.image = UIImage(named: "ThumbsUpWhite")
        }
        
        if myRamenPressed {
            myListLabel.text = "추가하기 취소"
            myListAddImageView.image = UIImage(named: "MyListBlack")
        } else {
            myListLabel.text = "추가하기"
            myListAddImageView.image = UIImage(named: "MyListWhite")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch reviewState {
        case .yet:
            reviewLabel.text = reviewState.rawValue
            guard let reviewImage = UIImage(named: "ReviewWhite") else { return }
            reviewImageView.image = reviewImage
        case .done:
            reviewLabel.text = reviewState.rawValue
            guard let reviewImage = UIImage(named: "ReviewBlack") else { return }
            reviewImageView.image = reviewImage
        default:
            fatalError()
        }
    }
    
    func getRamenImages() {
        let headers: HTTPHeaders = ["Authorization": "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"]
        let params: [String: Any] = ["query": information[index].place_name]
        AF.request(imageUrl, method: .get, parameters: params, headers: headers).responseDecodable(of: RamenImage.self) { response in
            if let dataImage = response.value {
                self.imageUrlList = (dataImage.documents[0].image_url, dataImage.documents[1].image_url)
            }
            
            DispatchQueue.main.async {
                if let firstImageUrl = self.imageUrlList.0 {
                    let urlOne = URL(string: firstImageUrl)
                    self.pictureImageViewOne.kf.setImage(with: urlOne)
                }
                
                if let secondImageUrl = self.imageUrlList.1 {
                    let urlTwo = URL(string: secondImageUrl)
                    self.pictureImageViewTwo.kf.setImage(with: urlTwo)
                }
            }
        }
    }
    
    func setUpBorder() {
        // TODO: $0이 Optional인 이유 찾기
        [addressView, numberView, timeView, pictureView, buttonsView, ratingLabel].forEach {
            $0!.layer.borderWidth = 2
            $0!.layer.borderColor = UIColor.black.cgColor
        }
        
        [buttonsView, ratingLabel].forEach {
            $0.layer.cornerRadius = 10
        }
        
        pictureImageViewOne.layer.addBorder([.right], color: .black, width: 2)
    }
    
    func setUpBackgroundColor() {
        [addressLabel, numberLabel, timeLabel].forEach {
            $0.backgroundColor = beige
        }
    }
    
    func setUpLableText() {
        let info = Array(information)
        storeLabel.text = info[index].place_name
        distanceLabel.text = "\(info[index].distance)m"
        addressLabel.text = info[index].road_address_name
        numberLabel.text = info[index].phone
    }
    
    func setUpTabImageView() {
        let goodTabGesture = UITapGestureRecognizer(target: self, action: #selector(goodMark))
        goodImageView.addGestureRecognizer(goodTabGesture)
        goodImageView.isUserInteractionEnabled = true
        
        let reviewTabGesture = UITapGestureRecognizer(target: self, action: #selector(reviewMark))
        reviewImageView.addGestureRecognizer(reviewTabGesture)
        reviewImageView.isUserInteractionEnabled = true
        
        let addTabGesture = UITapGestureRecognizer(target: self, action: #selector(addMyListMark))
        myListAddImageView.addGestureRecognizer(addTabGesture)
        myListAddImageView.isUserInteractionEnabled = true
    }
    
    @objc func goodMark() -> String {
        let goodObject = realm.objects(GoodListData.self).where {
            $0.storeName == store &&
            $0.x == location.0 &&
            $0.y == location.1
        }.first
        
        guard let rating = ratingLabel.text else { return "0" }
        let myRating = (rating as NSString).doubleValue
        storeRating = myRating
      
        if goodPressed {
            goodPressed = false
            goodLabel.text = "좋아요"
            goodImageView.image = UIImage(named: "ThumbsUpWhite")
            guard let goodObject = goodObject else { return ""}
            if let index = GoodListData.goodList.firstIndex(of: goodObject) {
                GoodListData.goodList.remove(at: index)
            }
            
            try! realm.write {
                realm.delete(goodObject)
            }
        } else {
            goodPressed = true
            goodLabel.text = "좋아요 취소"
            goodImageView.image = UIImage(named: "ThumbsUpBlack")
           
            guard let address = addressLabel.text else { return "" }
            let goodData = GoodListData(storeName: store, addressName: address, x: location.0, y: location.1, rating: storeRating, isGoodPressed: goodPressed)
            GoodListData.goodList.append(goodData)
                try! realm.write {
                    realm.add(goodData)
                    goodData.rating = storeRating
            }
        }
        
        return ""
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
            $0.storeName == storeName &&
            $0.x == location.0 &&
            $0.y == location.1
        }.first
        
        if myRamenPressed {
            myRamenPressed = false
            myListLabel.text = "추가하기"
            myListAddImageView.image = UIImage(named: "MyListWhite")
            guard let myListObject = myListObject else { return }
            
            if let index = MyRamenListData.myRamenList.firstIndex(of: myListObject) {
                MyRamenListData.myRamenList.remove(at: index)
            }
            
            try! realm.write {
                realm.delete(myListObject)
            }
        } else {
            myRamenPressed = true
            myListLabel.text = "추가하기 취소"
            if let rating = ratingLabel.text {
                myListAddImageView.image = UIImage(named: "MyListBlack")
                let myRating = (rating as NSString).doubleValue
                storeRating = myRating
                
                guard let address = addressLabel.text else { return }
                
                let myRamenData = MyRamenListData(storeName: store, address: address, x: location.0, y: location.1, rating: storeRating, myRamenPressed: myRamenPressed)
                MyRamenListData.myRamenList.append(myRamenData)
                try! realm.write {
                    realm.add(myRamenData)
                }
            } else {
                myListAddImageView.image = UIImage(named: "MyListBlack")
                guard let address = addressLabel.text else { return }
                
                let myRamenData = MyRamenListData(storeName: store, address: address, x: location.0, y: location.1, rating: 0, myRamenPressed: myRamenPressed)
                MyRamenListData.myRamenList.append(myRamenData)
                try! realm.write {
                    realm.add(myRamenData)
                }
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
