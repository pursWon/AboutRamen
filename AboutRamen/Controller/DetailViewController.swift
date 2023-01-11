import UIKit

class DetailViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet var storeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
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
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
    super.viewDidLoad()
    storeLabel.font = UIFont.boldSystemFont(ofSize: 40)
    locationLabel.layer.addBorder([.right], color: UIColor.black, width: 2.0)
    addressView.layer.addBorder([.top, .bottom], color: .black, width: 2.0)
    numberView.layer.addBorder([.bottom], color: .black, width: 2.0)
    timeView.layer.addBorder([.bottom], color: .black, width: 2.0)
    addressLabel.layer.addBorder([.left], color: .black, width: 2.0)
    numberLabel.layer.addBorder([.left], color: .black, width: 2.0)
    timeLabel.layer.addBorder([.left], color: .black, width: 2.0)
    buttonsView.layer.borderWidth = 2.0
    buttonsView.layer.borderColor = UIColor.black.cgColor
    buttonsView.layer.cornerRadius = 10
    ratingLabel.layer.borderWidth = 2.0
    ratingLabel.layer.borderColor = UIColor.black.cgColor
    ratingLabel.layer.cornerRadius = 10
    navigationItem.backBarButtonItem?.tintColor = UIColor.black
    addressLabel.backgroundColor = .systemOrange
    numberLabel.backgroundColor = .systemOrange
    timeLabel.backgroundColor = .systemOrange
    }
    // MARK: - Actions
    
    @IBAction func onDragStarSlider(_ sender: UISlider) {
        let floatValue = floor(sender.value * 10) / 10
        print(floatValue)
        for index in 1...5 {
            if let starImage = view.viewWithTag(index) as? UIImageView {
                if Float(index) <= floatValue {
                    starImage.image = UIImage(named: "별 한개")
                } else if (Float(index) - floatValue) <= 0.5 {
                    starImage.image = UIImage(named: "별 반개")
                } else {
                    starImage.image = UIImage(named: "빈 별")
                }
            }
        }
        ratingLabel.font = UIFont.boldSystemFont(ofSize: 15)
        ratingLabel.text = String("가게 평점 : \(floatValue)")
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
