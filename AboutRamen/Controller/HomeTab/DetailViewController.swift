import UIKit
import Alamofire
import Kingfisher

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
    @IBOutlet weak var starSlider: UISlider!
    @IBOutlet weak var starStackView: UIStackView!
    @IBOutlet var pictureView: UIView!
    @IBOutlet var pictureImageViewOne: UIImageView!
    @IBOutlet var pictureImageViewTwo: UIImageView!
    
    @IBOutlet var goodImageView: UIImageView!
    @IBOutlet var hateImageView: UIImageView!
    @IBOutlet var reviewImageView: UIImageView!
    @IBOutlet var myListAddImageView: UIImageView!
    
    @IBOutlet var goodLabel: UILabel!
    @IBOutlet var hateLabel: UILabel!
    @IBOutlet var reviewLabel: UILabel!
    @IBOutlet var myListLabel: UILabel!
    
    // MARK: - Properties
    var index: Int = 0
    var information: [Information] = []
    var searchIndex: Int = 0
    var isGoodPressed: Bool = true
    var isHatePressed: Bool = true
    var isReviewPressed: Bool = true
    var isMyListPressed: Bool = true
    var reviewState: ReviewState = .yet
    var imageUrlList: (String, String) = ("None", "None")
    let imageUrl: String = "https://dapi.kakao.com/v2/search/image"
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpBorder()
        setUpBackgroundColor()
        setUpLableText()
        setUpTabImageView()
        getRamenImages()
        storeLabel.font = UIFont.boldSystemFont(ofSize: 23)
        reviewLabel.text = reviewState.rawValue
        
        guard let reviewImage = UIImage(named: "ReviewWhite") else { return }
        reviewImageView.image = reviewImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reviewLabel.text = reviewState.rawValue
    }
    
    func getRamenImages() {
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
        storeLabel.text = information[index].place_name
        distanceLabel.text = "\(information[index].distance)m"
        addressLabel.text = information[index].road_address_name
        numberLabel.text = information[index].phone
    }
    
    func setUpTabImageView() {
        let goodTabGesture = UITapGestureRecognizer(target: self, action: #selector(goodMark))
        goodImageView.addGestureRecognizer(goodTabGesture)
        goodImageView.isUserInteractionEnabled = true
        
        let hateTabGesture = UITapGestureRecognizer(target: self, action: #selector(hateMark))
        hateImageView.addGestureRecognizer(hateTabGesture)
        hateImageView.isUserInteractionEnabled = true
        
        let reviewTabGesture = UITapGestureRecognizer(target: self, action: #selector(reviewMark))
        reviewImageView.addGestureRecognizer(reviewTabGesture)
        reviewImageView.isUserInteractionEnabled = true
        
        let addTabGesture = UITapGestureRecognizer(target: self, action: #selector(addMyListMark))
        myListAddImageView.addGestureRecognizer(addTabGesture)
        myListAddImageView.isUserInteractionEnabled = true
    }
    
    @objc func goodMark() {
        if let rating = ratingLabel.text {
            if isGoodPressed {
                goodImageView.image = UIImage(named: "ThumbsUpBlack")
                goodLabel.text = "좋아요 취소"
                isGoodPressed = false
                let goodListData = GoodListData(storeName: information[index].place_name, addressName: information[index].road_address_name, rating: rating, pressed: isGoodPressed, distance: information[index].distance, phone: information[index].phone)
                GoodListData.goodListArray.append(goodListData)
            } else {
                goodImageView.image = UIImage(named: "ThumbsUpWhite")
                goodLabel.text = "좋아요"
                isGoodPressed = true
            }
        } else {
            isGoodPressed = false
            let goodListData = GoodListData(storeName: information[index].place_name, addressName: information[index].road_address_name, rating: "0.0", pressed: isGoodPressed, distance: information[index].distance, phone: information[index].phone)
            GoodListData.goodListArray.append(goodListData)
        }
    }
    
    @objc func hateMark() {
        if isHatePressed {
            hateImageView.image = UIImage(named: "ThumbsDownBlack")
            hateLabel.text = "싫어요 취소"
            
            if let rating = ratingLabel.text {
                isHatePressed = false
                let badListData = BadListData(storeName: information[index].place_name, addressName: information[index].road_address_name, rating: rating, pressed: isHatePressed, distance: information[index].distance, phone: information[index].phone)
                BadListData.badListArray.append(badListData)
            } else {
                isHatePressed = false
                let badListData = BadListData(storeName: information[index].place_name, addressName: information[index].road_address_name, rating: "0.0", pressed: isHatePressed, distance: information[index].distance, phone: information[index].phone)
                BadListData.badListArray.append(badListData)
            }
        } else {
            hateImageView.image = UIImage(named: "ThumbsDownWhite")
            hateLabel.text = "싫어요"
            isHatePressed = true
        }
    }
    
    @objc func reviewMark() {
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
    
    @objc func addMyListMark() {
        if isMyListPressed, let rating = ratingLabel.text {
            myListAddImageView.image = UIImage(named: "MyListBlack")
            myListLabel.text = "추가하기 취소"
            isMyListPressed = false
            let myRamenListData = MyRamenListData(storeName: information[index].place_name, addressName: information[index].road_address_name, rating: rating, pressed: isMyListPressed, distance: information[index].distance, phone: information[index].phone)
            MyRamenListData.myRamenList.append(myRamenListData)
        } else if isMyListPressed {
            myListAddImageView.image = UIImage(named: "MyListBlack")
            myListLabel.text = "추가하기 취소"
            isMyListPressed = false
            let myRamenListData = MyRamenListData(storeName: information[index].place_name, addressName: information[index].road_address_name, rating: "0.0", pressed: isMyListPressed, distance: information[index].distance, phone: information[index].phone)
            MyRamenListData.myRamenList.append(myRamenListData)
        } else if !isMyListPressed {
            myListAddImageView.image = UIImage(named: "MyListWhite")
            myListLabel.text = "추가하기"
            isMyListPressed = true
        }
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

// MARK - ReviewCompleteProtocol
extension DetailViewController: ReviewCompleteProtocol {
    func sendReview(state: ReviewState, image: UIImage, sendReviewPressed: Bool) {
        reviewState = state
        reviewImageView.image = image
        isReviewPressed = sendReviewPressed
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
