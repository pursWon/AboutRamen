import UIKit
import RealmSwift

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
        
        view.backgroundColor = CustomColor.beige
        reviewView.backgroundColor = CustomColor.beige
        
        reviewTextView.delegate = self
        setUpTextViewBorder()
        setUpNavigationBarButton()
        setCustomBackButton(title: "가게 정보")
        
        guard let selectedRamen = selectedRamen else { return }
        reviewTextView.text = selectedRamen.reviewContent
        modifiedReview = selectedRamen.reviewContent ?? ""
        
        print(">>> review: \(selectedRamen._id) \(selectedRamen.storeName) \(selectedRamen.isReviewed)")
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
        completeButton.action = #selector(completeButtonAction)
        completeButton.target = self
    }
    
    // MARK: - Actions
    @objc func completeButtonAction() {
        guard let selectedRamen = selectedRamen else { return }
        // TODO: 좋아요를 안해도 리뷰작성할 수 있도록? (리뷰 작성 저장되게 수정하기. 좋아요 안하면 리뷰 못씀.)
        if reviewTextView.text.isEmpty {
            showAlert(title: "저장 실패", message: "내용이 비어있습니다.",alertStyle: .oneButton)
        } else {
            // TODO: 얼럿추가하고 싶으면 추가 (얼럿은 수정해야 됨)
            // if modifiedReview != selectedRamen.reviewContent {
            //     showAlert(title: "리뷰 내용이 바뀌었습니다.", message: "바뀐 내용으로 저장하시겠습니까?", alertStyle: .twoButton)
            // }
            
            if !selectedRamen.isGood || !selectedRamen.isFavorite {
                try! realm.write {
                    let reviewedItem = selectedRamen
                    reviewedItem.isReviewed = true
                    reviewedItem.reviewContent = reviewTextView.text
                    realm.add(selectedRamen)
                }
            } else {
                try! realm.write {
                    selectedRamen.reviewContent = reviewTextView.text
                    selectedRamen.isReviewed = true
                    realm.add(selectedRamen)
                }
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
