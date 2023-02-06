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
    
    // TODO: Image 이름에 공백이 없어야함, 이미지 이름은 영어로 지어야함
    // TODO: 이미지 없을 수도 있으므로, 강제 언랩핑을 하지 않고 시스템 이미지를 하나 지정해줄 것.
    func addIconImages() {
        if let iconImageOne = UIImage(named: "ThumbsUp"), let iconImageTwo = UIImage(named: "ThumbsDown"),
           let iconImageThree = UIImage(named: "ReviewBlack"), let iconImageFour = UIImage(named: "Ramen") {
            iconImages.append(iconImageOne)
            iconImages.append(iconImageTwo)
            iconImages.append(iconImageThree)
            iconImages.append(iconImageFour)
        } else {
            guard let systemImage = UIImage(systemName: "list.bullet.circle") else { return }
            iconImages.append(systemImage)
        }
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
            
            let backButton = UIBarButtonItem(title: "마이 리스트", style: .plain, target: self, action: nil)
            let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            
            self.navigationItem.backBarButtonItem = backButton
            self.navigationItem.backBarButtonItem?.tintColor = .black
            backButton.setTitleTextAttributes(attributes, for: .normal)
            
            navigationController?.pushViewController(goodListVC, animated: true)
            goodListVC.title = "좋아요 목록"
        case 1:
            guard let badListVC = self.storyboard?.instantiateViewController(withIdentifier: "BadListViewController") as? BadListViewController else { return }
            
            let backButton = UIBarButtonItem(title: "마이 리스트", style: .plain, target: self, action: nil)
            let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            
            self.navigationItem.backBarButtonItem = backButton
            self.navigationItem.backBarButtonItem?.tintColor = .black
            backButton.setTitleTextAttributes(attributes, for: .normal)
            
            navigationController?.pushViewController(badListVC, animated: true)
            badListVC.title = "싫어요 목록"
        case 2:
            guard let reviewListVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewListViewController") as? ReviewListViewController else { return }
            
            let backButton = UIBarButtonItem(title: "마이 리스트", style: .plain, target: self, action: nil)
            let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            
            self.navigationItem.backBarButtonItem = backButton
            self.navigationItem.backBarButtonItem?.tintColor = .black
            backButton.setTitleTextAttributes(attributes, for: .normal)
            
            navigationController?.pushViewController(reviewListVC, animated: true)
            reviewListVC.title = "리뷰 목록"
        case 3:
            guard let myRamenListVC = self.storyboard?.instantiateViewController(withIdentifier: "MyRamenListViewController") as? MyRamenListViewController else { return }
            
            let backButton = UIBarButtonItem(title: "마이 리스트", style: .plain, target: self, action: nil)
            let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            
            self.navigationItem.backBarButtonItem = backButton
            self.navigationItem.backBarButtonItem?.tintColor = .black
            backButton.setTitleTextAttributes(attributes, for: .normal)
            
            navigationController?.pushViewController(myRamenListVC, animated: true)
            myRamenListVC.title = "나의 라멘가게"
        default:
            fatalError()
        }
    }
}
