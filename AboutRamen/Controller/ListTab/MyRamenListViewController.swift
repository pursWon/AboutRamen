import UIKit

class MyRamenListViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var myRamenListTableView: UITableView!
    
    enum ViewType: String {
        case ramenList = "나의 라멘 가게"
        case goodList = "좋아요 목록"
        case badList = "싫어요 목록"
    }
    
    // MARK: - Properties
    var viewType: ViewType = .ramenList
    var uniqueMyRamenList: [RamenListData] = []
    var myRamenList: [Information] = []
    var uniqueGoodList: [RamenListData] = []
    var goodList: [Information] = []
    var uniqueBadList: [RamenListData] = []
    var badList: [Information] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewType.rawValue
        setUpTableView()
        removeDuplicate()
        view.backgroundColor = .systemOrange
    }
    
    func setUpTableView() {
        myRamenListTableView.delegate = self
        myRamenListTableView.dataSource = self
    }
    
    func removeDuplicate (_ array: [RamenListData]) -> [RamenListData] {
        var removedArray = [RamenListData]()
        
        for i in array {
            if !removedArray.contains(i) {
                removedArray.append(i)
            }
        }
        
        return removedArray
    }
    
    func removeDuplicate() {
        uniqueMyRamenList = removeDuplicate(DataStorage.myRamenList)
        uniqueGoodList = removeDuplicate(DataStorage.goodList)
        uniqueBadList = removeDuplicate(DataStorage.badList)
    }
}

// MARK: - TableView
extension MyRamenListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch title {
        case "나의 라멘 가게":
            switch uniqueMyRamenList.count {
            case 0:
                return 1
            default:
                return uniqueMyRamenList.count
            }
        case "좋아요 목록":
            switch uniqueGoodList.count {
            case 0:
                return 1
            default:
                return uniqueGoodList.count
            }
        case "싫어요 목록":
            switch uniqueBadList.count {
            case 0:
                return 1
            default:
                return uniqueBadList.count
            }
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRamenListCell", for: indexPath) as? MyRamenListCell else { return UITableViewCell() }
        switch title {
        case "나의 라멘 가게":
        if uniqueMyRamenList.count != 0 {
            cell.nameLabel.text = uniqueMyRamenList[indexPath.row].storeName
            cell.addressLabel.text = uniqueMyRamenList[indexPath.row].addressName
            cell.ratingLabel.text = uniqueMyRamenList[indexPath.row].rating
            myRamenList.append(Information(place_name: uniqueMyRamenList[indexPath.row].storeName, distance: uniqueMyRamenList[indexPath.row].distance, road_address_name: uniqueMyRamenList[indexPath.row].addressName, phone: uniqueMyRamenList[indexPath.row].phone))
        }
        
        case "좋아요 목록":
            if uniqueGoodList.count != 0 {
                cell.nameLabel.text = uniqueGoodList[indexPath.row].storeName
                cell.addressLabel.text = uniqueGoodList[indexPath.row].addressName
                cell.ratingLabel.text = uniqueGoodList[indexPath.row].rating
                goodList.append(Information(place_name: uniqueGoodList[indexPath.row].storeName, distance: uniqueGoodList[indexPath.row].distance, road_address_name: uniqueGoodList[indexPath.row].addressName, phone: uniqueGoodList[indexPath.row].phone))
            }
        
        case "싫어요 목록":
            if uniqueBadList.count != 0 {
                cell.nameLabel.text = uniqueBadList[indexPath.row].storeName
                cell.addressLabel.text = uniqueBadList[indexPath.row].addressName
                cell.ratingLabel.text = uniqueBadList[indexPath.row].rating
                badList.append(Information(place_name: uniqueBadList[indexPath.row].storeName, distance: uniqueBadList[indexPath.row].distance, road_address_name: uniqueBadList[indexPath.row].addressName, phone: uniqueBadList[indexPath.row].phone))
            }
            
        default:
            fatalError()
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
