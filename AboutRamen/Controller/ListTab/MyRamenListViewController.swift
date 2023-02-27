import UIKit
import RealmSwift

class MyRamenListViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var myRamenListTableView: UITableView!
    
    enum ViewType: String {
        case ramenList = "나의 라멘 가게"
        case goodList = "좋아요 목록"
    }
    
    // MARK: - Properties
    var viewType: ViewType = .ramenList
    var myRamenList = List<Information>()
    var goodList: [Information] = []
    
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
    
    func removeDuplicate() {
        let realm = try! Realm()
        let allRealmData = realm.objects(RealmData.self)
        for i in 0..<allRealmData.count {
            if allRealmData[i].isGoodPressed {
            
            }
        }
    }
}

// MARK: - TableView
extension MyRamenListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch title {
        case "좋아요 목록":
            switch ListDataStorage.goodList.count {
            case 0:
                return 1
            default:
                return ListDataStorage.goodList.count
            }
        case "나의 라멘 가게":
            switch ListDataStorage.myRamenList.count {
            case 0:
                return 1
            default:
                return ListDataStorage.myRamenList.count
            }
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRamenListCell", for: indexPath) as? MyRamenListCell else { return UITableViewCell() }
        switch title {
            
        case "좋아요 목록":
            if ListDataStorage.goodList.count != 0 {
                let goodList = Array(ListDataStorage.goodList)
                cell.nameLabel.text = goodList[indexPath.row].name
                cell.addressLabel.text = goodList[indexPath.row].address
                cell.ratingLabel.text = String(goodList[indexPath.row].rating)
            }
            
        case "나의 라멘 가게":
            if ListDataStorage.myRamenList.count != 0 {
                let myRamenList = Array(ListDataStorage.myRamenList)
                cell.nameLabel.text = myRamenList[indexPath.row].name
                cell.addressLabel.text = myRamenList[indexPath.row].address
                cell.ratingLabel.text = String(myRamenList[indexPath.row].rating)
            }
        default:
            fatalError()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        switch title {
        case "좋아요 목록":
            if ListDataStorage.goodList.count != 0 {
                detailVC.information = myRamenList
                detailVC.index = indexPath.row
                navigationController?.pushViewController(detailVC, animated: true)
            }
            
        case "나의 라멘 가게":
            if ListDataStorage.myRamenList.count != 0 {
                detailVC.information = myRamenList
                detailVC.index = indexPath.row
                navigationController?.pushViewController(detailVC, animated: true)
            }
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
