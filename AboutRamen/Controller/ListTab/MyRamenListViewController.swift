import UIKit
import RealmSwift
import Alamofire

class MyRamenListViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var myRamenListTableView: UITableView!
    
    enum ViewType: String {
        case ramenList = "나의 라멘 가게"
        case goodList = "좋아요 목록"
    }
    
    // MARK: - Properties
    let realm = try! Realm()
    var viewType: ViewType = .ramenList
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    var ramenList = List<Information>()
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewType.rawValue
        setUpTableView()
        view.backgroundColor = .systemOrange
        
        let goodList = realm.objects(GoodListData.self)
        let myRamenList = realm.objects(MyRamenListData.self)
        
    }
    
    func setUpTableView() {
        myRamenListTableView.delegate = self
        myRamenListTableView.dataSource = self
    }
    
    func getData(url: String, storeName: String, x: String, y: String) {
        let headers: HTTPHeaders = ["Authorization": "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"]
        let parameters: [String: Any] = [
            "query" : storeName,
            "x" : x,
            "y" : y
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RamenStore.self) {
        response in
            if let data = response.value {
            self.ramenList = data.documents
            } else {
                print("통신 실패")
            }
        }
    }
}

// MARK: - TableView
extension MyRamenListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let goodList = realm.objects(GoodListData.self)
        let myRamenList = realm.objects(MyRamenListData.self)
        
        switch title {
        case "좋아요 목록":
            switch goodList.count {
            case 0:
                return 1
            default:
                return goodList.count
            }
            
        case "나의 라멘 가게":
            switch myRamenList.count {
            case 0:
                return 1
            default:
                return myRamenList.count
            }
            
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRamenListCell", for: indexPath) as? MyRamenListCell else { return UITableViewCell() }
        let goodList = realm.objects(GoodListData.self)
        let myRamenList = realm.objects(MyRamenListData.self)
        
        switch title {
            
        case "좋아요 목록":
            if !goodList.isEmpty {
                cell.nameLabel.text = goodList[indexPath.row].storeName
                cell.addressLabel.text = goodList[indexPath.row].addressName
                cell.ratingLabel.text = String(goodList[indexPath.row].rating)
            }
            
        case "나의 라멘 가게":
            if !myRamenList.isEmpty {
                cell.nameLabel.text = myRamenList[indexPath.row].storeName
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
        let goodList = realm.objects(GoodListData.self)
        let myRamenList = realm.objects(MyRamenListData.self)
        switch title {
            
        case "좋아요 목록":
            if goodList.count != 0 {
                // detailVC.information = ramenList
                // detailVC.index = indexPath.row
                // navigationController?.pushViewController(detailVC, animated: true)
            }
            
        case "나의 라멘 가게":
            if myRamenList.count != 0 {
                let information = ramenList.filter { $0.place_name == myRamenList[indexPath.row].storeName &&
                    $0.x == String(myRamenList[indexPath.row].x)
            }
                if let information = information.first {
                    detailVC.information.append(information)
                    print(detailVC.information)
                    navigationController?.pushViewController(detailVC, animated: true)
                }
                
                getData(url: url, storeName: myRamenList[indexPath.row].storeName, x: String(myRamenList[indexPath.row].x), y: String(myRamenList[indexPath.row].y))
                
            }
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
