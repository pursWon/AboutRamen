import UIKit
import CoreLocation
import Alamofire
import RealmSwift

/// 나의 라면 가게 화면
class MyRamenListViewController: UIViewController {
    // MARK: - View Type
    enum ViewType: String {
        case goodList = "좋아요 목록"
        case favoriteList = "나의 라멘 가게"
    }
    
    // MARK: - UI
    @IBOutlet var emptyLabel: UILabel!
    @IBOutlet var myRamenListTableView: UITableView!
    
    // MARK: - Properties
    let realm = try! Realm()
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    let appid = Bundle.main.apiKey
    
    var viewType: ViewType = .goodList
    var storeList: Results<RamenData>?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitData()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        myRamenListTableView.reloadData()
    }
    
    // MARK: - Set up
    func setInitData() {
        title = viewType.rawValue
        view.backgroundColor = CustomColor.beige
    }
    
    func setUpTableView() {
        myRamenListTableView.delegate = self
        myRamenListTableView.dataSource = self
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MyRamenListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let storeList = storeList else { return 0 }
        emptyLabel.isHidden = storeList.isEmpty ? false : true
        return storeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRamenListCell", for: indexPath) as? MyRamenListCell else { return UITableViewCell() }
        guard let storeList = storeList else { return UITableViewCell() }
        
        let item = storeList[indexPath.row]
        cell.nameLabel.text = item.storeName
        cell.addressLabel.text = item.addressName
        cell.starImage.tintColor = .systemOrange
        
        switch viewType {
        case .goodList:
            cell.ratingLabel.text = String(item.rating)
            cell.starImage.image = UIImage(systemName: "heart.fill")
            
        case .favoriteList:
            cell.ratingLabel.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        guard let storeList = storeList, !storeList.isEmpty else { return }
        let selectedRamen = storeList[indexPath.row]
        
        switch viewType {
        case .goodList:
            detailVC.viewType = .goodList
            
        case .favoriteList:
            detailVC.viewType = .favoriteList
        }
        
        detailVC.selectedRamen = selectedRamen
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
