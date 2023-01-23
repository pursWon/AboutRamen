import UIKit
import Alamofire

class HomeViewController: UIViewController, SampleProtocol, LngLgtProtocol {
    // MARK: - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var regionChangeButton: UIBarButtonItem!
    @IBOutlet var myLocationLabel: UILabel!
    // MARK: - Properties
    let url: String = "https://dapi.kakao.com/v2/local/search/keyword.json"
    var ramenList: [Information] = []
    var region: String = ""
    let regionData = RegionData()
    var myLngLgt: (Double, Double) = (127.0495556, 37.514575)
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        setUpNavigationBar()
        getAlamofire(url: url, lnglgt: myLngLgt)
        myLocationLabel.text = "서울시 강남구"
    }
    
    func sendData(data: String) {
        myLocationLabel.text = data
    }
    
    func sendLngLgt(lnglgt: (Double, Double)) {
        myLngLgt = lnglgt
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAlamofire(url: url, lnglgt: myLngLgt)
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

    func getAlamofire(url: String, lnglgt: (Double, Double)) {
        
        let headers: HTTPHeaders = [
            "Authorization" : "KakaoAK d8b066a3dbb0e888b857f37b667d96d2"
        ]
        
        let parameters: [String : Any] = [
            "query" : "라멘",
            "x" : "\(lnglgt.0)",
            "y" : "\(lnglgt.1)",
            "radius" : 7000,
            "size" : 15
        ]
        
        AF.request(url, method: .get, parameters: parameters ,headers: headers).responseDecodable(of: RamenStore.self) {
            response in
            debugPrint(response.value)
            
            if let data = response.value {
                self.ramenList = data.documents
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    @IBAction func regionChangeButton(_ sender: UIBarButtonItem) {
        guard let regionPickerVC = self.storyboard?.instantiateViewController(withIdentifier: "RegionPickerController") as? RegionPickerController else { return }
        regionPickerVC.delegate = self
        regionPickerVC.delegateLngLgt = self
        navigationController?.pushViewController(regionPickerVC, animated: true)
    }
}
// MARK: - Collecion View
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
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



