import UIKit
import RealmSwift

/// 리뷰 목록 화면
class ReviewListViewController: UIViewController {
    // MARK: - UI
    @IBOutlet var reviewListTableView: UITableView!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var emptyLabel: UILabel!
    
    // MARK: - Properties
    let realm = try! Realm()
    var reviewList: Results<RamenData>?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setInitData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reviewListTableView.reloadData()
    }
    
    // MARK: - Set Up
    func setInitData() {
        title = "리뷰 목록"
        view.backgroundColor = CustomColor.ground
        editButton.titleLabel?.font = AppFont.title(15)
        editButton.setTitleColor(CustomColor.accent, for: .normal)

        emptyLabel.font = AppFont.caption
        emptyLabel.textColor = CustomColor.inkSoft
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.text = "아직 작성한 리뷰가 없습니다.\n가게 정보에서 리뷰를 남겨보세요."
    }

    func setUpTableView() {
        reviewListTableView.dataSource = self
        reviewListTableView.delegate = self
        reviewListTableView.backgroundColor = CustomColor.ground
        reviewListTableView.separatorColor = CustomColor.hairline
    }
    
    // MARK: - Action
    @IBAction func editButton(_ sender: UIButton) {
        let attributes = [NSAttributedString.Key.font: AppFont.title(15)]
        var text = NSAttributedString(string: "편집", attributes: attributes)
        if reviewListTableView.isEditing {
            editButton.setAttributedTitle(text, for: .normal)
            reviewListTableView.setEditing(false, animated: true)
        } else {
            text = NSAttributedString(string: "완료", attributes: attributes)
            editButton.setAttributedTitle(text, for: .normal)
            reviewListTableView.setEditing(true, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ReviewListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reviewList = reviewList else { return 0 }
        
        emptyLabel.isHidden = reviewList.isEmpty ? false : true
        return reviewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = reviewListTableView.dequeueReusableCell(withIdentifier: "ReviewListCell", for: indexPath) as? ReviewListCell else { return UITableViewCell() }
        
        guard let reviewList = reviewList else { return UITableViewCell() }
        
        let item = reviewList[indexPath.row]

        cell.backgroundColor = CustomColor.surface
        cell.nameLabel.text = item.storeName
        cell.nameLabel.font = AppFont.storeName
        cell.nameLabel.textColor = CustomColor.ink
        cell.addressLabel.text = item.addressName
        cell.addressLabel.font = AppFont.address
        cell.addressLabel.textColor = CustomColor.inkSoft
        cell.reviewImageView.tintColor = CustomColor.accent

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else { return }
        
        guard let reviewList = reviewList else { return }
        
        reviewVC.selectedRamen = reviewList[indexPath.row]
        setCustomBackButton(title: "리뷰 목록")
        navigationController?.pushViewController(reviewVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let reviewList = reviewList else { return }
        
        if editingStyle == .delete {
            let item = reviewList[indexPath.row]

            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("리뷰 삭제 실패: \(error)")
                showAlert(title: "삭제하지 못했습니다", message: "잠시 후 다시 시도해 주세요.", alertStyle: .oneButton)
            }

            reviewListTableView.reloadData()
        }
    }
}
