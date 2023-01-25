import UIKit

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
    
    // MARK: - Properties
    var index: Int = 0
    var information: [Information] = []
    var searchIndex: Int = 0
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpBorder()
        setUpBackgroundColor()
        setUpLableText()
        storeLabel.font = UIFont.boldSystemFont(ofSize: 23)
    }
    
    @IBAction func reviewButton(_ sender: UIButton) {
        guard let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else { return }
        navigationController?.pushViewController(reviewVC, animated: true)
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
        print(information[index].place_name)
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
        ratingLabel.text = String("가게 평점 : \(value)")
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


