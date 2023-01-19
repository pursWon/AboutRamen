import UIKit

class ViewController: UIViewController {
    // MARK: - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var regionChangeButton: UIBarButtonItem!
    @IBOutlet var myLocationLabel: UILabel!
    // MARK: - Properties
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json?query=%EB%9D%BC%EB%A9%98&x=126.8468194&y=37.29851944&radius=7000&page=1"
    var ramenList: [Information] = []
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        setUpNavigationBar()
        getRamenInformation()
    }
    
    func setUpNavigationBar() {
        title = "어바웃라멘"
        view.backgroundColor = .systemOrange
        regionChangeButton.tintColor = .black
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "BlackHanSans-Regular", size: 20)!]
        regionChangeButton.setTitleTextAttributes(attributes, for: .normal)
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "BlackHanSans-Regular", size: 30)!]
        }
        
        myLocationLabel.font = UIFont.init(name: "RecipeKorea", size: 17)
    }
    
    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemOrange
    }
    
    func getRamenInformation() {
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK d8b066a3dbb0e888b857f37b667d96d2", forHTTPHeaderField: "Authorization")
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            guard let response = response as? HTTPURLResponse else { return }
            guard error == nil else { return }
            
            switch response.statusCode {
            case 200:
                let data = try? JSONDecoder().decode(RamenStore.self, from: data)
                
                if let data = data {
                    self.ramenList = data.documents
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } else {
                    print("파싱 실패!")
                }
                
            default:
                print("데이터 연결 실패!")
            }
        }
        dataTask.resume()
    }
}
// MARK: - Collecion View
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ramenList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        let ramenData = ramenList[indexPath.row]
        print(ramenData)
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 3
        cell.layer.cornerRadius = 10
        
        cell.nameLabel.textAlignment = .center
        cell.nameLabel.font = .boldSystemFont(ofSize: 15)
        cell.starLabel.font = .boldSystemFont(ofSize: 15)
        
        cell.nameLabel.text = ramenData.place_name
        cell.distanceLabel.text = "\(ramenData.distance) m"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        let widthSpacing: CGFloat = 20
        let heightSpacing: CGFloat = 60
        let widthCount: CGFloat = 2
        let heightCount: CGFloat = 3
        let totalWidth = (width - (widthSpacing * (widthCount - 1))) / widthCount
        let totalHeight = (height - (heightSpacing * (heightCount - 1))) / heightCount
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.index = indexPath.row
        detailVC.information = ramenList
        navigationController?.pushViewController(detailVC, animated: true)
    }
}



