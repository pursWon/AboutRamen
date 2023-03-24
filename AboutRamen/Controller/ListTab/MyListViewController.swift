import UIKit

class MyListViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var myListTableView: UITableView!
    
    // MARK: - Properties
    let menuItems: [(title: String, icon: UIImage)] = [("좋아요 목록", CustomImage.thumbsUp), ("리뷰 목록", CustomImage.reviewBlack), ("나의 라멘 가게", CustomImage.ramen)]
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUptableView()
        view.backgroundColor = CustomColor.beige
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Recipekorea", size: 20)!]
    }
    
    func setUptableView() {
        myListTableView.dataSource = self
        myListTableView.delegate = self
    }
}

// MARK: - TableView
extension MyListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = myListTableView.dequeueReusableCell(withIdentifier: "MyListCell", for: indexPath) as? MyListCell else { return UITableViewCell() }
        cell.contentLabel.text = menuItems[indexPath.row].title
        cell.contentLabel.font = UIFont.boldSystemFont(ofSize: 30)
        cell.listImageView.image = menuItems[indexPath.row].icon
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            guard let goodListVC = self.storyboard?.instantiateViewController(withIdentifier: "MyRamenListVC") as? MyRamenListViewController else { return }
            
            goodListVC.viewType = .goodList
            let backButton = UIBarButtonItem(title: "마이 리스트", style: .plain, target: self, action: nil)
            let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            
            self.navigationItem.backBarButtonItem = backButton
            self.navigationItem.backBarButtonItem?.tintColor = .black
            backButton.setTitleTextAttributes(attributes, for: .normal)
            
            navigationController?.pushViewController(goodListVC, animated: true)
       
        case 1:
            guard let reviewListVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewListVC") as? ReviewListViewController else { return }
            
            let backButton = UIBarButtonItem(title: "마이 리스트", style: .plain, target: self, action: nil)
            let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            
            self.navigationItem.backBarButtonItem = backButton
            self.navigationItem.backBarButtonItem?.tintColor = .black
            backButton.setTitleTextAttributes(attributes, for: .normal)
            
            navigationController?.pushViewController(reviewListVC, animated: true)
        
        case 2:
            guard let myRamenListVC = self.storyboard?.instantiateViewController(withIdentifier: "MyRamenListVC") as? MyRamenListViewController else { return }
            
            let backButton = UIBarButtonItem(title: "마이 리스트", style: .plain, target: self, action: nil)
            let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            
            self.navigationItem.backBarButtonItem = backButton
            self.navigationItem.backBarButtonItem?.tintColor = .black
            backButton.setTitleTextAttributes(attributes, for: .normal)
            
            navigationController?.pushViewController(myRamenListVC, animated: true)
        default:
            fatalError()
        }
    }
}
