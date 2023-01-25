import UIKit

class BadListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI
    @IBOutlet var badListTableView: UITableView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        view.backgroundColor = .systemOrange
    }
    
    func setUpTableView() {
        badListTableView.dataSource = self
        badListTableView.delegate = self
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = badListTableView.dequeueReusableCell(withIdentifier: "BadListCell", for: indexPath) as? BadListCell else { return UITableViewCell() }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
