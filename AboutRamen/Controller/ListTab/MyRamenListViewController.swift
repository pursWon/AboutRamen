import UIKit

class MyRamenListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI
    @IBOutlet var myRamenListTableView: UITableView!
    
    // MARK: - Properties
    var uniqueMyRamenList: [MyRamenListData] = []
    var myRamenList: [Information] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        removeDuplicate()
        view.backgroundColor = .systemOrange
    }
    
    func setUpTableView() {
        myRamenListTableView.delegate = self
        myRamenListTableView.dataSource = self
    }
    
    func removeDuplicate (_ array: [MyRamenListData]) -> [MyRamenListData] {
        var removedArray = [MyRamenListData]()
        
        for i in array {
            if removedArray.contains(i) == false {
                removedArray.append(i)
            }
        }
        
        return removedArray
    }
    
    func removeDuplicate() {
        uniqueMyRamenList = removeDuplicate(MyRamenListData.myRamenList)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch uniqueMyRamenList.count {
        case 0:
            return 1
        default:
            return uniqueMyRamenList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRamenListCell", for: indexPath) as? MyRamenListCell else { return UITableViewCell() }
        if uniqueMyRamenList.count != 0 {
        cell.nameLabel.text = uniqueMyRamenList[indexPath.row].storeName
        cell.addressLabel.text = uniqueMyRamenList[indexPath.row].addressName
        cell.ratingLabel.text = uniqueMyRamenList[indexPath.row].rating
        myRamenList.append(Information(place_name: uniqueMyRamenList[indexPath.row].storeName, distance: uniqueMyRamenList[indexPath.row].distance, road_address_name: uniqueMyRamenList[indexPath.row].addressName, phone: uniqueMyRamenList[indexPath.row].phone))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        if uniqueMyRamenList.count != 0 {
        detailVC.information = myRamenList
        detailVC.index = indexPath.row
        navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
