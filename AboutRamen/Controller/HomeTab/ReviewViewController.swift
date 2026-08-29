import UIKit
import RealmSwift

/// 리뷰 작성 화면
class ReviewViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var reviewTextView: UITextView!
    @IBOutlet var reviewView: UIView!
    
    //MARK: - Properties
    /// 순환 참조를 막기 위해 weak으로 잡는다 (프로토콜은 AnyObject로 제한)
    weak var delegate: ReviewCompleteProtocol?
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
        view.backgroundColor = CustomColor.ground
        reviewView.backgroundColor = CustomColor.ground

        guard let selectedRamen = selectedRamen else { return }
        reviewTextView.text = selectedRamen.reviewContent
        modifiedReview = selectedRamen.reviewContent ?? ""
    }

    func setUpTextView() {
        reviewTextView.delegate = self

        // 2.5pt 검정 테두리 대신 흰 카드 + 헤어라인
        reviewTextView.backgroundColor = CustomColor.surface
        reviewTextView.textColor = CustomColor.ink
        reviewTextView.font = AppFont.body(15)
        reviewTextView.layer.borderColor = CustomColor.hairline.cgColor
        reviewTextView.layer.borderWidth = 1
        reviewTextView.layer.cornerRadius = 14
        reviewTextView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
    }

    func setUpNavigationBarButton() {
        let attributes = [NSAttributedString.Key.font: AppFont.barButton]
        let completeButton = UIBarButtonItem(title: "리뷰 완료", style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = completeButton
        navigationItem.rightBarButtonItem?.tintColor = CustomColor.accent
        completeButton.setTitleTextAttributes(attributes, for: .normal)
        completeButton.action = #selector(completeButtonAction)
        completeButton.target = self
    }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previous) else { return }
        reviewTextView.layer.borderColor = CustomColor.hairline.cgColor
    }
    
    // MARK: - Actions
    @objc func completeButtonAction() {
        guard let selectedRamen = selectedRamen else { return }
        
        if reviewTextView.text.isEmpty {
            showAlert(title: "저장 실패", message: "내용이 비어있습니다.", alertStyle: .oneButton)
            return
        }

        let reviewText = reviewTextView.text ?? ""

        let didSave = RamenStorage.write { realm in
            selectedRamen.isReviewed = true
            selectedRamen.reviewContent = reviewText

            realm.add(selectedRamen, update: .modified)
        }

        guard didSave else {
            showAlert(title: "저장하지 못했습니다", message: "잠시 후 다시 시도해 주세요.", alertStyle: .oneButton)
            return
        }

        delegate?.sendReview(state: .done)
        navigationController?.popViewController(animated: true)
    }
}

extension ReviewViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        modifiedReview = textView.text
    }
}
