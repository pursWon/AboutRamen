import UIKit
import RealmSwift

/// 리스트 목록 화면
class MyListViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var myListTableView: UITableView!
    
    // MARK: - Properties
    let realm = try! Realm()
    let menuItems: [(title: String, icon: UIImage)] = [
        ("좋아요 목록", CustomImage.thumbsUp),
        ("리뷰 목록", CustomImage.reviewBlack),
        ("나의 라멘 가게", CustomImage.ramen)]
    
    var goodList: Results<RamenData>?
    var reviewList: Results<RamenData>?
    var favoriteList: Results<RamenData>?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitData()
        setuptableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        deleteNoDataItem()
        getList()
    }
    
    // MARK: - Set Up
    func setInitData() {
        view.backgroundColor = CustomColor.beige
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Recipekorea", size: 20)!]
    }
    
    func setuptableView() {
        myListTableView.dataSource = self
        myListTableView.delegate = self
    }
    
    // MARK: - ETC
    /// 평가가 모두 안되어 있는 아이템 삭제
    func deleteNoDataItem() {
        let shouldDeleteItems = realm.objects(RamenData.self).filter { !$0.isGood && !$0.isReviewed && !$0.isFavorite }
        
        if !shouldDeleteItems.isEmpty {
            try! realm.write {
                realm.delete(shouldDeleteItems)
            }
        }
    }
    
    func getList() {
        goodList = realm.objects(RamenData.self).filter("isGood == true")
        reviewList = realm.objects(RamenData.self).filter("isReviewed == true")
        favoriteList = realm.objects(RamenData.self).filter("isFavorite == true")
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MyListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = myListTableView.dequeueReusableCell(withIdentifier: "MyListCell", for: indexPath) as? MyListCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.contentLabel.font = UIFont(name: "Recipekorea", size: 17)
        cell.contentLabel.text = menuItems[indexPath.row].title
        cell.listImageView.image = menuItems[indexPath.row].icon
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyRamenListVC") as? MyRamenListViewController else { return }
            
            vc.viewType = .goodList
            vc.storeList = goodList
            setCustomBackButton(title: "마이 리스트")
            navigationController?.pushViewController(vc, animated: true)
            
        case 1:
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewListVC") as? ReviewListViewController else { return }
            
            vc.reviewList = reviewList
            setCustomBackButton(title: "마이 리스트")
            navigationController?.pushViewController(vc, animated: true)
            
        case 2:
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyRamenListVC") as? MyRamenListViewController else { return }
            
            vc.viewType = .favoriteList
            vc.storeList = favoriteList
            setCustomBackButton(title: "마이 리스트")
            navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
