import UIKit
import Alamofire
import Kingfisher
import RealmSwift

enum ReviewState: String {
    case yet = "리뷰하기"
    case done = "리뷰완료"
}

protocol ReviewCompleteProtocol {
    func sendReview(state: ReviewState, image: UIImage, sendReviewPressed: Bool)
}

class DetailViewController: UIViewController {
    // MARK: - UI
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
    var index: Int = 0
    var information: List<Information>?
    var searchIndex: Int = 0
    var reviewState: ReviewState = .yet
    var imageUrlList: (String, String) = ("None", "None")
    let imageUrl: String = "https://dapi.kakao.com/v2/search/image"
    let realm = try! Realm()
    var goodPressed: Bool = false
    var store: String = ""
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange
        setUpBorder()
        setUpBackgroundColor()
        setUpLableText()
        setUpTabImageView()
        getRamenImages()
        setListValue()
        storeLabel.font = UIFont.boldSystemFont(ofSize: 35)
        reviewLabel.text = reviewState.rawValue
        starRatingView.delegate = self
        starRatingView.contentMode = .scaleAspectFit
        if let storeName = storeLabel.text {
        store = storeName
        }
        guard let reviewImage = UIImage(named: "ReviewWhite") else { return }
        reviewImageView.image = reviewImage
        
        let allRealmData = realm.objects(RealmData.self)
        for i in 0..<allRealmData.count {
            if allRealmData[i].storeName == storeLabel.text {
                print(allRealmData[i].isGoodPressed)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reviewLabel.text = reviewState.rawValue
    }
    
    func setListValue() {
        let all = realm.objects(RealmData.self)
        
        if !goodPressed {
            goodLabel.text = "좋아요"
            goodImageView.image = UIImage(named: "ThumbsUpWhite")
        } else {
            goodLabel.text = "좋아요 취소"
            goodImageView.image = UIImage(named: "ThumbsUpBlack")
        }
    }
    
    func getRamenImages() {
        guard let information = information else { return }
        let headers: HTTPHeaders = ["Authorization": "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"]
        let params: [String: Any] = ["query": information[index].place_name]
        AF.request(imageUrl, method: .get, parameters: params, headers: headers).responseDecodable(of: RamenImage.self) { response in
            if let dataImage = response.value {
                self.imageUrlList = (dataImage.documents[0].image_url, dataImage.documents[1].image_url)
            }
            
            DispatchQueue.main.async {
                let urlOne = URL(string: self.imageUrlList.0)
                let urlTwo = URL(string: self.imageUrlList.1)
                self.pictureImageViewOne.kf.setImage(with: urlOne)
                self.pictureImageViewTwo.kf.setImage(with: urlTwo)
            }
        }
    }
    
    func setUpBorder() {
        let views: [UIView] = [addressView, numberView, timeView, pictureView]
        views.forEach {
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.black.cgColor
        }
        
        let others: [UIView] = [buttonsView, ratingLabel]
        others.forEach {
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.black.cgColor
            $0.layer.cornerRadius = 10
        }
        
        pictureImageViewOne.layer.addBorder([.right], color: .black, width: 2.0)
    }
    
    func setUpBackgroundColor() {
        let labels: [UILabel] = [addressLabel, numberLabel, timeLabel]
        labels.forEach {
            $0.backgroundColor = .systemOrange
        }
    }
    
    func setUpLableText() {
        guard let information = information else { return }
        storeLabel.text = information[index].place_name
        distanceLabel.text = "\(information[index].distance)m"
        addressLabel.text = information[index].road_address_name
        numberLabel.text = information[index].phone
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
    
    @objc func goodMark() {
        guard let storeName = storeLabel.text else { return }
        let update = realm.objects(RealmData.self).where {
            $0.storeName == storeName
        }.first!
        
        if goodPressed == false {
            goodPressed = true
            goodImageView.image = UIImage(named: "ThumbsUpBlack")
            goodLabel.text = "좋아요 취소"
            try! realm.write {
                update.isGoodPressed = true
            }
        } else if goodPressed == true {
            goodPressed = false
            goodImageView.image = UIImage(named: "ThumbsUpWhite")
            goodLabel.text = "좋아요"
            try! realm.write {
                update.isGoodPressed = false
            }
        }
    }
    
    @objc func reviewMark() {
        guard let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else { return }
        guard let information = information else { return }
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
    
    @objc func addMyListMark() {
        let allRealmData = realm.objects(RealmData.self)
        // if !isMyListPressed {
        //     isMyListPressed = true
        //     myListAddImageView.image = UIImage(named: "MyListBlack")
        //     if let rating = ratingLabel.text {
        //         for i in 0..<allRealmData.count {
        //             if storeLabel.text == allRealmData[i].storeName {
        //                 guard let myRating = NumberFormatter().number(from: rating)?.doubleValue else { return }
        //                 if let isMyRamenPressed = realm.objects(RealmData.self).filter(NSPredicate(format: "isMyRamenPressed = %@", allRealmData[i].isMyRamenPressed)).first,
        //                    let rating = realm.objects(RealmData.self).filter(NSPredicate(format: "rating = %@", allRealmData[i].isMyRamenPressed)).first {
        //                     try! realm.write {
        //                         isMyRamenPressed.isMyRamenPressed = isMyListPressed
        //                         rating.rating = myRating
        //                     }
        //                 }
        //                 ListDataStorage.myRamenList.insert(ListDataStorage(name: allRealmData[i].storeName, address: addressLabel.text ?? "x", rating: myRating))
        //             }
        //         }
        //     } else {
        //         for i in 0..<allRealmData.count {
        //             if storeLabel.text == allRealmData[i].storeName {
        //                 if let myRamenPressed = realm.objects(RealmData.self).filter(NSPredicate(format: "isMyRamenPressed = %@", allRealmData[i].isMyRamenPressed)).first,
        //                    let rating = realm.objects(RealmData.self).filter(NSPredicate(format: "rating = %@", allRealmData[i].rating)).first {
        //                     try! realm.write {
        //                         myRamenPressed.isMyRamenPressed = isMyListPressed
        //                         rating.rating = 0
        //                     }
        //                 }
        //                 ListDataStorage.myRamenList.insert(ListDataStorage(name: allRealmData[i].storeName, address: addressLabel.text ?? "x", rating: 0))
        //             }
        //         }
        //     }
        // } else if isMyListPressed {
        //     isMyListPressed = false
        //     myListAddImageView.image = UIImage(named: "MyListWhite")
        //     for i in 0..<allRealmData.count {
        //         if storeLabel.text == allRealmData[i].storeName {
        //             if let myRamenPressed = realm.objects(RealmData.self).filter(NSPredicate(format: "isMyRamenPressed = %@", allRealmData[i].isMyRamenPressed)).first {
        //                 try! realm.write {
        //                     myRamenPressed.isMyRamenPressed = isMyListPressed
        //                 }
        //             }
        //             if let indexToRemove = ListDataStorage.myRamenList.firstIndex(of: ListDataStorage(name: allRealmData[i].storeName, address: addressLabel.text ?? "x", rating: allRealmData[i].rating)) {
        //                 ListDataStorage.myRamenList.remove(at: indexToRemove)
        //             }
        //         }
        //     }
    }
    
    // MARK: - Actions
    @IBAction func onDragStarSlider(_ sender: UISlider) {
        let floatValue = (floor(sender.value * 10) / 10)
        var value: Float = 0
        
        switch floatValue {
        case 0:
            value = 0
        case 0.1...0.5:
            value = 0.5
        case 0.6...1.0:
            value = 1.0
        case 1.1...1.5:
            value = 1.5
        case 1.6...2.0:
            value = 2.0
        case 2.1...2.5:
            value = 2.5
        case 2.6...3:
            value = 3.0
        case 3.1...3.5:
            value = 3.5
        case 3.6...4.0:
            value = 4.0
        case 4.1...4.5:
            value = 4.5
        case 4.5...5.0:
            value = 5.0
        default:
            fatalError()
        }
        
        for index in 1...5 {
            if let starImage = view.viewWithTag(index) as? UIImageView {
                if Float(index) <= value {
                    starImage.image = UIImage(named: "OneStar")
                } else if (Float(index) - value) <= 0.5 {
                    starImage.image = UIImage(named: "HalfStar")
                } else {
                    starImage.image = UIImage(named: "EmptyStar")
                }
            }
        }
        
        ratingLabel.font = UIFont.boldSystemFont(ofSize: 15)
        ratingLabel.text = String("\(value)")
    }
}

extension DetailViewController: ReviewCompleteProtocol {
    func sendReview(state: ReviewState, image: UIImage, sendReviewPressed: Bool) {
        reviewState = state
        reviewImageView.image = image
    }
}

extension CALayer {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}

extension DetailViewController: RatingViewDelegate {
    func ratingView(_ ratingView: RatingView, isUpdating rating: Double) {
        ratingLabel.text = String(rating)
    }
}
