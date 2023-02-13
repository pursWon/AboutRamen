import UIKit

class ReviewListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI
    @IBOutlet var reviewListTableView: UITableView!
    
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
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch DataStorage.storeReviews.count {
        case 0:
            return 1
        default:
            return DataStorage.storeReviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = reviewListTableView.dequeueReusableCell(withIdentifier: "ReviewListCell", for: indexPath) as? ReviewListCell else { return UITableViewCell() }
        
        if DataStorage.storeReviews.count != 0 {
            cell.nameLabel.text = DataStorage.storeReviews[indexPath.row].storeName
            cell.addressLabel.text = DataStorage.storeReviews[indexPath.row].addressName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else { return }
        if DataStorage.storeReviews.count != 0 {
            reviewVC.reviewContent = DataStorage.storeReviews[indexPath.row].reviewContent
            reviewVC.storeName = DataStorage.storeReviews[indexPath.row].storeName
            navigationController?.pushViewController(reviewVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
