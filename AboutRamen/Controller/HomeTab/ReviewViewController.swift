import UIKit
import RealmSwift

class ReviewViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var reviewTextView: UITextView!
    @IBOutlet var reviewView: UIView!
    
    //MARK: - Properties
    let realm = try! Realm()
    var delegate: ReviewCompleteProtocol?
    var storeName: String = ""
    var addressName: String = ""
    var reviewContent: String = ""
    var modifyReview: String = ""
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = CustomColor.beige
        reviewView.backgroundColor = CustomColor.beige
        
        setUpTextViewBorder()
        setUpNavigationBarButton()
        
        reviewTextView.text = modifyReview.isEmpty ? " " : modifyReview
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
        let reviewList = realm.objects(ReviewListData.self)
        var storeNameArray: [String] = []
        
        for i in 0..<reviewList.count {
            storeNameArray.append(reviewList[i].storeName)
        }
        
        if modifyReview.isEmpty {
            if reviewTextView.text.isEmpty {
                showAlert(title: "리뷰 항목이 비어있습니다.", alertStyle: .oneButton)
            } else {
                if storeNameArray.contains(storeName) {
                    showAlert(title: "해당 가게가 이미 리스트에 존재합니다.", alertStyle: .oneButton)
                } else {
                    try! realm.write {
                        realm.add(ReviewListData(storeName: storeName, addressName: addressName, reviewContent: reviewTextView.text))
                    }
                    
                    delegate?.sendReview(state: .done)
                    navigationController?.popViewController(animated: true)
                }
            }
        } else {
            if reviewTextView.text.isEmpty {
                showAlert(title: "리뷰 항목이 비어있습니다.", alertStyle: .oneButton)
            } else {
                showAlert(title: "수정하시겠습니까?", alertStyle: .twoButton)
                modifyReview = reviewTextView.text
                let reviewUpdate = realm.objects(ReviewListData.self).where {
                    $0.storeName == storeName && $0.addressName == addressName
                }.first
                
                try! realm.write {
                    if let reviewUpdate = reviewUpdate {
                        reviewUpdate.reviewContent = reviewTextView.text
                    }
                }
                
                delegate?.sendReview(state: .done)
            }
        }
    }
}
