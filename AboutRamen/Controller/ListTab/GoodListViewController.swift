import UIKit

class GoodListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI
    @IBOutlet var goodListTableView: UITableView!
    var goodRamenList: [Information] = []
    var good: [GoodListData] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpNavigationBar()
        removeDuplicate()
    }
    
    func setUpNavigationBar() {
        view.backgroundColor = .systemOrange
        navigationController?.navigationBar.backgroundColor = .systemOrange
    }
    
    func setUpTableView() {
        goodListTableView.delegate = self
        goodListTableView.dataSource = self
    }
    
    func removeDuplicate (_ array: [GoodListData]) -> [GoodListData] {
        var removedArray = [GoodListData]()
        for i in array {
            if removedArray.contains(i) == false {
                removedArray.append(i)
            }
        }
        
        return removedArray
    }
    
    func removeDuplicate() {
        good = removeDuplicate(GoodListData.goodListArray)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return good.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = goodListTableView.dequeueReusableCell(withIdentifier: "GoodListCell", for: indexPath) as? GoodListCell else { return UITableViewCell() }
        print(good)
        if good.count != 0 {
            cell.storeLabel.text = good[indexPath.row].storeName
            cell.addressLabel.text = good[indexPath.row].addressName
            cell.ratingLabel.text = good[indexPath.row].rating
            goodRamenList.append(Information(place_name: good[indexPath.row].storeName,
                                                        distance: good[indexPath.row].distance,  road_address_name: good[indexPath.row].addressName, phone: good[indexPath.row].phone))
        } else {
            cell.storeLabel.text = "비어 있음"
            cell.addressLabel.text = "비어 있음"
            cell.ratingLabel.text = "비어 있음"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.information = goodRamenList
        detailVC.index = indexPath.row
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
