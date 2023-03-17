import UIKit
import RealmSwift

class ReviewListViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var reviewListTableView: UITableView!
    
    // MARK: - Properties
    let realm = try! Realm()
    let beige = UIColor(red: 255/255, green: 231/255, blue: 204/255, alpha: 1.0)
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        view.backgroundColor = beige
        title = "리뷰 목록"
    }
    
    func setUpTableView() {
        reviewListTableView.dataSource = self
        reviewListTableView.delegate = self
    }
}

// MARK: - TableView
extension ReviewListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let reviewList = realm.objects(ReviewListData.self)
        return reviewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = reviewListTableView.dequeueReusableCell(withIdentifier: "ReviewListCell", for: indexPath) as? ReviewListCell else { return UITableViewCell() }
        let reviewList = realm.objects(ReviewListData.self)
        if reviewList.count != 0 {
            cell.nameLabel.text = reviewList[indexPath.row].storeName
            cell.addressLabel.text = reviewList[indexPath.row].addressName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else { return }
        let reviewList = realm.objects(ReviewListData.self)
        
        if reviewList.count != 0 {
            let content = reviewList.where {
                $0.storeName == reviewList[indexPath.row].storeName &&
                $0.addressName == reviewList[indexPath.row].addressName
            }.first
            
            guard let content = content else { return }
            
            reviewVC.storeName = reviewList[indexPath.row].storeName
            reviewVC.addressName = reviewList[indexPath.row].addressName
            reviewVC.modifyReview = content.reviewContent
            navigationController?.pushViewController(reviewVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let reviewList = realm.objects(ReviewListData.self)
        let reviewArray = Array(reviewList)
        
        if editingStyle == .delete {
            let item = reviewArray[indexPath.row]
            
            try! realm.write {
                realm.delete(item)
            }
            
            reviewListTableView.reloadData()
        }
    }
}
