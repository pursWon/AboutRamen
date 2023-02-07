import UIKit

class GoodListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI
    @IBOutlet var goodListTableView: UITableView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setUpNavigationBar()
    }
    
    func setUpNavigationBar() {
        view.backgroundColor = .systemOrange
        navigationController?.navigationBar.backgroundColor = .systemOrange
    }
    
    func setUpTableView() {
        goodListTableView.delegate = self
        goodListTableView.dataSource = self
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = goodListTableView.dequeueReusableCell(withIdentifier: "GoodListCell", for: indexPath)
                as? GoodListCell else { return UITableViewCell() }
        
        let goodDataList = GoodListData.goodListArray
        
        if goodDataList.count != 0 {
            cell.storeLabel.text = goodDataList[indexPath.row].storeName
            cell.addressLabel.text = goodDataList[indexPath.row].addressName
            cell.ratingLabel.text = goodDataList[indexPath.row].rating
        } else {
            cell.storeLabel.text = "비어 있음"
            cell.addressLabel.text = "비어 있음"
            cell.ratingLabel.text = "비어 있음"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
