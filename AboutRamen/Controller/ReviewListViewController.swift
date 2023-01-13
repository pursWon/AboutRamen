import UIKit

class ReviewListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI
    @IBOutlet var reviewListTableView: UITableView!
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        navigationController?.navigationBar.backgroundColor = .systemOrange
    }
    
    func setUpTableView() {
        reviewListTableView.dataSource = self
        reviewListTableView.delegate = self
    }
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = reviewListTableView.dequeueReusableCell(withIdentifier: "ReviewListCell", for: indexPath) as? ReviewListCell else { return UITableViewCell() }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
