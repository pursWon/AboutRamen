import UIKit

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
    var reviewImage: UIImage = UIImage(named: "평가하기")!
    var reviewState: ReviewState = .yet
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpBorder()
        setUpBackgroundColor()
        setUpLableText()
        setUpTabImageView()
        storeLabel.font = UIFont.boldSystemFont(ofSize: 23)
        reviewLabel.text = reviewState.rawValue
        reviewImageView.image = reviewImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reviewLabel.text = reviewState.rawValue
        reviewImageView.image = reviewImage
    }
    
    func setUpBorder() {
        let views: [UIView] = [addressView, numberView, timeView, pictureView]
        views.forEach {
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.black.cgColor
        }
        
        pictureImageViewOne.layer.addBorder([.right], color: .black, width: 2)
        
        let others: [UIView] = [buttonsView, ratingLabel]
        others.forEach {
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.black.cgColor
            $0.layer.cornerRadius = 10
        }
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
        if isGoodPressed == true {
            goodImageView.image = UIImage(named: "엄지 척 누른 상태")
            goodLabel.text = "좋아요 취소"
            
            if let rating = ratingLabel.text {
                isGoodPressed = false
                let goodListData = GoodListData(storeName: information[index].place_name, addressName: information[index].road_address_name, rating: rating, pressed: isGoodPressed, distance: information[index].distance, phone: information[index].phone)
                GoodListData.goodListArray.append(goodListData)
            } else {
                isGoodPressed = false
                let goodListData = GoodListData(storeName: information[index].place_name, addressName: information[index].road_address_name, rating: "0.0", pressed: isGoodPressed, distance: information[index].distance, phone: information[index].phone)
                GoodListData.goodListArray.append(goodListData)
            }
            
        } else if isGoodPressed == false {
            goodImageView.image = UIImage(named: "엄지 척")
            goodLabel.text = "좋아요"
            isGoodPressed = true
        }
    }
    
    @objc func hateMark() {
        if isHatePressed == true {
            hateImageView.image = UIImage(named: "엄지 아래 누른 상태")
            hateLabel.text = "싫어요 취소"
            isHatePressed = false
        } else if isHatePressed == false {
            hateImageView.image = UIImage(named: "엄지 아래")
            hateLabel.text = "싫어요"
            isHatePressed = true
        }
    }
    
    @objc func reviewMark() {
        guard let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else { return }
        
        reviewVC.delegate = self
        
        let backButton = UIBarButtonItem(title: "가게 정보", style: .plain, target: self, action: nil)
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        
        self.navigationItem.backBarButtonItem = backButton
        self.navigationItem.backBarButtonItem?.tintColor = .black
        backButton.setTitleTextAttributes(attributes, for: .normal)
        
        navigationController?.pushViewController(reviewVC, animated: true)
    }
    
    @objc func addMyListMark() {
        if isMyListPressed == true {
            myListAddImageView.image = UIImage(named: "마이 리스트 누른 후")
            myListLabel.text = "추가하기 취소"
            isMyListPressed = false
        } else if isMyListPressed == false {
            myListAddImageView.image = UIImage(named: "마이 리스트 누르기 전")
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
                    starImage.image = UIImage(named: "별 한개")
                } else if (Float(index) - value) <= 0.5 {
                    starImage.image = UIImage(named: "별 반개")
                } else {
                    starImage.image = UIImage(named: "빈 별")
                }
            }
        }
        
        ratingLabel.font = UIFont.boldSystemFont(ofSize: 15)
        ratingLabel.text = String("\(value)")
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

// MARK - ReviewCompleteProtocol
extension DetailViewController: ReviewCompleteProtocol {
    func sendReview(state: ReviewState, image: UIImage, sendReviewPressed: Bool) {
        reviewState = state
        reviewImage = image
        isReviewPressed = sendReviewPressed
    }
}
