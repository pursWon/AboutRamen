import UIKit

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
        
        self.nameLabel.textAlignment = .left
        self.nameLabel.font = .boldSystemFont(ofSize: 12)
        self.starLabel.font = .boldSystemFont(ofSize: 15)
    }
}
