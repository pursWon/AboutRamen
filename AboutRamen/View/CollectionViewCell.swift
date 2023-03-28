import UIKit

/// 홈 - 라면 정보 셀
class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ramenView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var ramenImageView: UIImageView!
    
    func cellConfigure() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 3
        self.layer.cornerRadius = 10
        
        self.starLabel.font = .boldSystemFont(ofSize: 15)
        self.nameLabel.textAlignment = .left
        self.nameLabel.font = .boldSystemFont(ofSize: 12)
        
        self.ramenImageView.layer.borderWidth = 1.5
        self.ramenImageView.layer.borderColor = UIColor.black.cgColor
        self.ramenImageView.layer.cornerRadius = 10
    }
}
