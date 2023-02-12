import UIKit

class BadListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI
    @IBOutlet var badListTableView: UITableView!
    
    // MARK: - Properties
    var uniqueBadList: [BadListData] = []
    var badRamenList: [Information] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeDuplicate()
        setUpTableView()
        view.backgroundColor = .systemOrange
    }
    
    func setUpTableView() {
        badListTableView.dataSource = self
        badListTableView.delegate = self
    }
    
    func removeDuplicate (_ array: [BadListData]) -> [BadListData] {
        var removedArray = [BadListData]()
        
        for i in array {
            if removedArray.contains(i) == false {
                removedArray.append(i)
            }
        }
        
        return removedArray
    }
    
    func removeDuplicate() {
        uniqueBadList = removeDuplicate(BadListData.badListArray)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch uniqueBadList.count {
        case 0:
            return 1
        default:
            return uniqueBadList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = badListTableView.dequeueReusableCell(withIdentifier: "BadListCell", for: indexPath) as? BadListCell else { return UITableViewCell() }
        if uniqueBadList.count != 0 {
            cell.storeLabel.text = uniqueBadList[indexPath.row].storeName
            cell.addressLabel.text = uniqueBadList[indexPath.row].addressName
            cell.ratingLabel.text = uniqueBadList[indexPath.row].rating
            badRamenList.append(Information(place_name: uniqueBadList[indexPath.row].storeName, distance: uniqueBadList[indexPath.row].distance, road_address_name: uniqueBadList[indexPath.row].addressName, phone: uniqueBadList[indexPath.row].phone))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        if uniqueBadList.count != 0 {
        detailVC.information = badRamenList
        detailVC.index = indexPath.row
        navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
