import UIKit

class ReviewViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var reviewTextView: UITextView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange
        
        reviewTextView.layer.borderColor = UIColor.black.cgColor
        reviewTextView.layer.borderWidth = 2.5
        reviewTextView.layer.cornerRadius = 10
    }
    
    // MARK: - Actions
    @IBAction func reviewCompleteButton(_ sender: UIBarButtonItem) {
        
    }
}
