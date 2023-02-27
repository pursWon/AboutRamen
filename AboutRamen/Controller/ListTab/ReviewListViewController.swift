import UIKit
import RealmSwift

class ReviewListViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var reviewListTableView: UITableView!
    
    // MARK: - Properties
    let realm = try! Realm()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        view.backgroundColor = .systemOrange
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
        switch ListDataStorage.reviewList.count {
        case 0:
            return 1
        default:
            return ListDataStorage.reviewList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = reviewListTableView.dequeueReusableCell(withIdentifier: "ReviewListCell", for: indexPath) as? ReviewListCell else { return UITableViewCell() }
        let reviewList = Array(ListDataStorage.reviewList)
        if ListDataStorage.reviewList.count != 0 {
            cell.nameLabel.text = reviewList[indexPath.row].name
            cell.addressLabel.text = reviewList[indexPath.row].address
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else { return }
        let reviewList = Array(ListDataStorage.reviewList)
        let allRealmData = realm.objects(RealmData.self)
        
        if ListDataStorage.reviewList.count != 0 {
            reviewVC.storeName = reviewList[indexPath.row].name
            for i in 0..<allRealmData.count {
                if reviewList[indexPath.row].name == allRealmData[i].storeName {
                    reviewVC.reviewContent = allRealmData[i].reviewContent
                    navigationController?.pushViewController(reviewVC, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
