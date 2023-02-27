import UIKit
import RealmSwift

class ReviewViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var reviewTextView: UITextView!
    
    //MARK: - Properties
    var delegate: ReviewCompleteProtocol?
    var storeName: String = ""
    var addressName: String = ""
    var reviewContent: String = ""
    var modifyReview: String = ""
    let realm = try! Realm()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange
        
        setUpTextViewBorder()
        setUpNavigationBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reviewTextView.text = reviewContent
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
        let allRealmData = realm.objects(RealmData.self)
        var storeNameArray: [String] = []
        for content in ListDataStorage.reviewList {
            storeNameArray.append(content.name)
        }
        
        if reviewTextView.text.count != 0, !storeNameArray.contains(storeName) {
            for i in 0..<allRealmData.count {
                if storeName == allRealmData[i].storeName {
                    if let review = realm.objects(RealmData.self).filter(NSPredicate(format: "reviewContent = %@", allRealmData[i].reviewContent)).first {
                        try! realm.write {
                            review.reviewContent = reviewTextView.text
                        }
                    }
                    ListDataStorage.reviewList.insert(ListDataStorage(name: storeName, address: addressName, rating: 0))
                    delegate?.sendReview(state: .done, image: UIImage(named: "ReviewBlack")!, sendReviewPressed: false)
                    navigationController?.popViewController(animated: true)
                }
            }
        } else if reviewTextView.text.count != 0, storeNameArray.contains(storeName), reviewContent.count == 0 {
            listAlert()
        } else if reviewTextView.text.count != 0, storeNameArray.contains(storeName), reviewContent.count != 0 {
            if reviewTextView.text.count != 0 {
                modifyReview = reviewTextView.text
                for i in 0..<allRealmData.count {
                    if storeName == allRealmData[i].storeName {
                        if let review = realm.objects(RealmData.self).filter(NSPredicate(format: "reviewContent = %@", allRealmData[i].reviewContent)).first {
                            try! realm.write {
                                review.reviewContent = modifyReview
                            }
                        }
                    }
                }
            }
            correctAlert()
        } else {
            blankTextAlert()
        }
    }
}
