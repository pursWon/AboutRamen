import UIKit
import RealmSwift

class ReviewViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var reviewTextView: UITextView!
    
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
    
    /// savedText는 기존 realm에 존재하는 review 문자열, reviewText는 새로 작성한 review 문자열
    func writeRealm(savedText: String ,reviewText: String) {
        // if let review = realm.objects(RealmData.self).filter(NSPredicate(format: "reviewContent = %@", savedText)).first {
        //     try! realm.write {
        //         review.reviewContent = reviewText
        //     }
        // }
    }
    
    // MARK: - Actions
    @objc func completeButtonAction() {
        // let allRealmData = realm.objects(RealmData.self)
        var storeNameArray: [String] = []
        
        for content in ListDataStorage.reviewList {
            storeNameArray.append(content.name)
        }
        
        if !reviewTextView.text.isEmpty {
            if !storeNameArray.contains(storeName) {
                // for i in 0..<allRealmData.count {
                //     if storeName == allRealmData[i].storeName {
                //         writeRealm(savedText: allRealmData[i].reviewContent, reviewText: reviewTextView.text)
                //         
                //         ListDataStorage.reviewList.insert(ListDataStorage(name: storeName, address: addressName, rating: 0))
                //         delegate?.sendReview(state: .done, image: UIImage(named: "ReviewBlack")!, sendReviewPressed: false)
                //         navigationController?.popViewController(animated: true)
                //     }
                // }
            } else {
                if reviewContent.isEmpty {
                    listAlert()
                } else {
                    modifyReview = reviewTextView.text
                    // for i in 0..<allRealmData.count {
                    //     if storeName == allRealmData[i].storeName {
                    //         writeRealm(savedText: allRealmData[i].reviewContent, reviewText: modifyReview)
                    //     }
                    // }
                    
                    correctAlert()
                }
            }
        } else {
            blankTextAlert()
        }
    }
}
