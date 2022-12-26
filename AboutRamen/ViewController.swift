import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemOrange
        title = "어바웃라멘"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25)]
        navigationController?.navigationBar.layer.borderWidth = 1
        navigationController?.navigationBar.layer.borderColor = UIColor.black.cgColor
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 3
        cell.layer.cornerRadius = 10
        
        cell.nameLabel.layer.borderColor = UIColor.black.cgColor
        cell.nameLabel.layer.borderWidth = 1
        cell.nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        cell.nameLabel.layer.cornerRadius = 5
        
        cell.starLabel.layer.borderColor = UIColor.black.cgColor
        cell.starLabel.layer.borderWidth = 1
        cell.starLabel.font = UIFont.boldSystemFont(ofSize: 20)
        cell.starLabel.layer.cornerRadius = 5
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let interSpacing: CGFloat = 30
        let lineCount: CGFloat = 2
        let totalWidth = (width - (interSpacing * (lineCount - 1))) / lineCount
        return CGSize(width: totalWidth, height: totalWidth)
    }
}

