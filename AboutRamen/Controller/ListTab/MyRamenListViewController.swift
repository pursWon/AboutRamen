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
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    let appid = Bundle.main.apiKey
    
    var viewType: ViewType = .goodList
    var storeList: Results<RamenData>?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setInitData()
        setUpTableView()
        setupNavigationbar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        myRamenListTableView.reloadData()
    }

    // MARK: - Set up
    func setInitData() {
        title = viewType.rawValue
        view.backgroundColor = CustomColor.ground

        emptyLabel.font = AppFont.caption
        emptyLabel.textColor = CustomColor.inkSoft
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.text = viewType == .goodList
            ? "아직 좋아요한 가게가 없습니다.\n마음에 드는 가게에 좋아요를 눌러보세요."
            : "아직 추가한 가게가 없습니다.\n가게 정보에서 나의 라멘 가게에 추가해보세요."
    }

    func setUpTableView() {
        myRamenListTableView.delegate = self
        myRamenListTableView.dataSource = self
        myRamenListTableView.backgroundColor = CustomColor.ground
        myRamenListTableView.separatorColor = CustomColor.hairline
    }

    func setupNavigationbar() {
        let mapButton = UIBarButtonItem(image: UIImage(systemName: "map"), style: .plain, target: self, action: #selector(mapButtonTapped))
        navigationItem.rightBarButtonItem = mapButton
    }

    // MARK: - Action
    @objc func mapButtonTapped() {
        guard let storeList = storeList, !storeList.isEmpty else { return }

        let mapVC = MapViewController()
        mapVC.stores = Array(storeList)

        setCustomBackButton(title: viewType.rawValue)
        navigationController?.pushViewController(mapVC, animated: true)
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

        cell.backgroundColor = CustomColor.surface
        cell.nameLabel.text = item.storeName
        cell.nameLabel.font = AppFont.storeName
        cell.nameLabel.textColor = CustomColor.ink
        cell.addressLabel.text = item.addressName
        cell.addressLabel.font = AppFont.address
        cell.addressLabel.textColor = CustomColor.inkSoft

        // 별점 표기는 모든 화면에서 star.fill + accent로 통일한다
        cell.starImage.tintColor = CustomColor.accent

        switch viewType {
        case .goodList:
            let hasRating = item.rating > 0
            cell.ratingLabel.isHidden = !hasRating
            cell.starImage.isHidden = !hasRating
            cell.ratingLabel.text = hasRating ? String(format: "%.1f", item.rating) : nil
            cell.ratingLabel.font = AppFont.body(15)
            cell.ratingLabel.textColor = CustomColor.ink
            cell.starImage.image = UIImage(systemName: "star.fill")

        case .favoriteList:
            cell.ratingLabel.isHidden = true
            cell.starImage.isHidden = false
            cell.starImage.image = UIImage(systemName: "bookmark.fill")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        guard let storeList = storeList, !storeList.isEmpty else { return }
        let selectedRamen = storeList[indexPath.row]
        
        switch viewType {
        case .goodList:
            setCustomBackButton(title: "좋아요 목록")
            detailVC.viewType = .goodList
            
        case .favoriteList:
            setCustomBackButton(title: "나의 라멘 가게")
            detailVC.viewType = .favoriteList
        }
        
        detailVC.selectedRamen = selectedRamen
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
