import UIKit

class BadListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI
    @IBOutlet var badListTableView: UITableView!
    
    // MARK: - Properties
    var bad: [BadListData] = []
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
        bad = removeDuplicate(BadListData.badListArray)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bad.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = badListTableView.dequeueReusableCell(withIdentifier: "BadListCell", for: indexPath) as? BadListCell else { return UITableViewCell() }
        if bad.count != 0 {
            cell.storeLabel.text = bad[indexPath.row].storeName
            cell.addressLabel.text = bad[indexPath.row].addressName
            cell.ratingLabel.text = bad[indexPath.row].rating
            badRamenList.append(Information(place_name: bad[indexPath.row].storeName, distance: bad[indexPath.row].distance, road_address_name: bad[indexPath.row].addressName, phone: bad[indexPath.row].phone))
        } else {
            cell.storeLabel.text = "비어 있음"
            cell.addressLabel.text = "비어 있음"
            cell.ratingLabel.text = "비어 있음"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.information = badRamenList
        detailVC.index = indexPath.row
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
