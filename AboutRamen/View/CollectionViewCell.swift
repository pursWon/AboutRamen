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
        self.layer.borderWidth = 2.5
        self.layer.cornerRadius = 10
        
        self.distanceLabel.clipsToBounds = true
        self.distanceLabel.layer.cornerRadius = 3
        self.distanceLabel.font = .boldSystemFont(ofSize: 13)
        self.distanceLabel.backgroundColor = .black.withAlphaComponent(0.4)
        
        self.starLabel.font = .boldSystemFont(ofSize: 13)
        self.starLabel.backgroundColor = .black.withAlphaComponent(0.4)
        
        self.nameLabel.textAlignment = .left
        self.nameLabel.font = UIFont(name: "Recipekorea", size: 11.5)
    }
}
