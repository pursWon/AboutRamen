import UIKit
import RealmSwift

/// 리뷰 작성 화면
class ReviewViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var reviewTextView: UITextView!
    @IBOutlet var reviewView: UIView!
    
    //MARK: - Properties
    let realm = try! Realm()
    var delegate: ReviewCompleteProtocol?
    var selectedRamen: RamenData?
    var modifiedReview: String = ""
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitData()
        setUpTextView()
        setUpNavigationBarButton()
        setCustomBackButton(title: "가게 정보")
    }
    
    // MARK: - Set Up
    func setInitData() {
        view.backgroundColor = CustomColor.beige
        reviewView.backgroundColor = CustomColor.beige
        
        guard let selectedRamen = selectedRamen else { return }
        reviewTextView.text = selectedRamen.reviewContent
        modifiedReview = selectedRamen.reviewContent ?? ""
    }
    
    func setUpTextView() {
        reviewTextView.delegate = self
        reviewTextView.layer.borderColor = UIColor.black.cgColor
        reviewTextView.layer.borderWidth = 2.5
        reviewTextView.layer.cornerRadius = 10
    }
    
    func setUpNavigationBarButton() {
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Recipekorea", size: 15)]
        let completeButton = UIBarButtonItem(title: "리뷰 완료", style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = completeButton
        navigationItem.rightBarButtonItem?.tintColor = .black
        completeButton.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
        completeButton.action = #selector(completeButtonAction)
        completeButton.target = self
    }
    
    // MARK: - Actions
    @objc func completeButtonAction() {
        guard let selectedRamen = selectedRamen else { return }
        
        if reviewTextView.text.isEmpty {
            showAlert(title: "저장 실패", message: "내용이 비어있습니다.",alertStyle: .oneButton)
        } else {
            try! realm.write {
                selectedRamen.isReviewed = true
                selectedRamen.reviewContent = reviewTextView.text
                
                realm.add(selectedRamen)
            }
            
            delegate?.sendReview(state: .done)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension ReviewViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        modifiedReview = textView.text
    }
}
