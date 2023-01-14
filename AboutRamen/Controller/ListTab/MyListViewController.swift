import UIKit

class MyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI
    @IBOutlet var myListTableView: UITableView!
    // MARK: - Properties
    let listNameArray: [String] = ["좋아요 목록", "싫어요 목록", "평가 목록", "나의 라멘 가게"]
    var iconImages: [UIImage] = []
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addIconImages()
        setUptableView()
        view.backgroundColor = .systemOrange
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Recipekorea", size: 20)!]
    }
    
    func addIconImages() {
        iconImages.append(UIImage(named: "엄지 척 리스트버전")!)
        iconImages.append(UIImage(named: "엄지 아래 리스트버전")!)
        iconImages.append(UIImage(named: "평가하기 리스트버전")!)
        iconImages.append(UIImage(named: "라멘")!)
    }
    
    func setUptableView() {
        myListTableView.dataSource = self
        myListTableView.delegate = self
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = myListTableView.dequeueReusableCell(withIdentifier: "MyListCell", for: indexPath) as? MyListCell else { return UITableViewCell() }
        cell.contentLabel.text = listNameArray[indexPath.row]
        cell.contentLabel.font = UIFont.boldSystemFont(ofSize: 30)
        cell.listImageView.image = iconImages[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            guard let goodListVC = self.storyboard?.instantiateViewController(withIdentifier: "GoodListViewController") as? GoodListViewController else { return }
            navigationController?.pushViewController(goodListVC, animated: true)
            goodListVC.title = "좋아요 목록"
        case 1:
            guard let badListVC = self.storyboard?.instantiateViewController(withIdentifier: "BadListViewController") as? BadListViewController else { return }
            navigationController?.pushViewController(badListVC, animated: true)
            badListVC.title = "싫어요 목록"
        case 2:
            guard let reviewListVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewListViewController") as? ReviewListViewController else { return }
            navigationController?.pushViewController(reviewListVC, animated: true)
            reviewListVC.title = "리뷰 목록"
        case 3:
            guard let myRamenListVC = self.storyboard?.instantiateViewController(withIdentifier: "MyRamenListViewController") as? MyRamenListViewController else { return }
            navigationController?.pushViewController(myRamenListVC, animated: true)
            myRamenListVC.title = "나의 라멘가게"
        default:
            fatalError()
        }
    }
}
