import UIKit
import RealmSwift

class ReviewViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var reviewTextView: UITextView!
    @IBOutlet var reviewView: UIView!
    
    //MARK: - Properties
    let realm = try! Realm()
    let beige = UIColor(red: 255/255, green: 231/255, blue: 204/255, alpha: 1.0)
    var delegate: ReviewCompleteProtocol?
    var storeName: String = ""
    var addressName: String = ""
    var reviewContent: String = ""
    var modifyReview: String = ""
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = beige
        reviewView.backgroundColor = beige
        
        setUpTextViewBorder()
        setUpNavigationBarButton()
        
        if modifyReview.isEmpty {
            reviewTextView.text = ""
        } else {
            reviewTextView.text = modifyReview
        }
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
        
        switch modifyReview.isEmpty {
        
        case true:
        if reviewTextView.text.isEmpty {
            blankTextAlert()
        } else {
            if storeNameArray.contains(storeName) {
                listAlert()
            } else {
                try! realm.write {
                    realm.add(ReviewListData(storeName: storeName, addressName: addressName, reviewContent: reviewTextView.text))
                }
                
                delegate?.sendReview(state: .done)
                navigationController?.popViewController(animated: true)
            }
        }
            
        case false:
            if reviewTextView.text.isEmpty {
                blankTextAlert()
            } else {
                correctAlert()
                modifyReview = reviewTextView.text
                let reviewUpdate = realm.objects(ReviewListData.self).where {
                    $0.storeName == storeName &&
                    $0.addressName == addressName
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
