import UIKit

class GoodListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI
    @IBOutlet var goodListTableView: UITableView!
    // MARK: - Properties
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        navigationController?.navigationBar.backgroundColor = .systemOrange
    }
    
    func setUpTableView() {
        goodListTableView.delegate = self
        goodListTableView.dataSource = self
    }
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = goodListTableView.dequeueReusableCell(withIdentifier: "GoodListCell", for: indexPath) as?
                GoodListCell else { return UITableViewCell() }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
