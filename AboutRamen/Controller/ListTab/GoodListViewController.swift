import UIKit

class GoodListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI
    @IBOutlet var goodListTableView: UITableView!
    
    // MARK: - Properties
    var goodRamenList: [Information] = []
    var uniqueGoodList: [GoodListData] = []
    
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
        uniqueGoodList = removeDuplicate(GoodListData.goodListArray)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch uniqueGoodList.count {
        case 0:
            return 1
        default:
            return uniqueGoodList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = goodListTableView.dequeueReusableCell(withIdentifier: "GoodListCell", for: indexPath) as? GoodListCell else { return UITableViewCell() }
        if uniqueGoodList.count != 0 {
            cell.storeLabel.text = uniqueGoodList[indexPath.row].storeName
            cell.addressLabel.text = uniqueGoodList[indexPath.row].addressName
            cell.ratingLabel.text = uniqueGoodList[indexPath.row].rating
            goodRamenList.append(Information(place_name: uniqueGoodList[indexPath.row].storeName,
                                                        distance: uniqueGoodList[indexPath.row].distance,  road_address_name: uniqueGoodList[indexPath.row].addressName, phone: uniqueGoodList[indexPath.row].phone))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        if uniqueGoodList.count != 0 {
        detailVC.information = goodRamenList
        detailVC.index = indexPath.row
        navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
