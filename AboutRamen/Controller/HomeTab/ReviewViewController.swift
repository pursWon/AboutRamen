import UIKit

class ReviewViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var reviewTextView: UITextView!
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange
        
        setUpTextViewBorder()
        setUpNavigationBarButton()
    }
    
    func setUpTextViewBorder() {
        reviewTextView.layer.borderColor = UIColor.black.cgColor
        reviewTextView.layer.borderWidth = 2.5
        reviewTextView.layer.cornerRadius = 10
    }
    
    func setUpNavigationBarButton() {
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        let completeButton = UIBarButtonItem(title: "리뷰 완료", style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = completeButton
        self.navigationItem.rightBarButtonItem?.tintColor = .black
        completeButton.setTitleTextAttributes(attributes, for: .normal)
    }
    
    // MARK: - Actions

}
