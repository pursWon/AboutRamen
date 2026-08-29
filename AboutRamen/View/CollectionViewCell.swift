import UIKit

/// 홈 - 라면 정보 셀
class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ramenView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var ramenImageView: UIImageView!
    
    func cellConfigure() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.08
        self.layer.shadowRadius = 6
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.masksToBounds = false

        self.ramenView.layer.cornerRadius = 16
        self.ramenView.layer.masksToBounds = true
        self.ramenView.layer.borderWidth = 1
        self.ramenView.layer.borderColor = CustomColor.cardBorder.cgColor

        self.distanceLabel.clipsToBounds = true
        self.distanceLabel.layer.cornerRadius = 8
        self.distanceLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        self.distanceLabel.backgroundColor = .black.withAlphaComponent(0.45)

        self.starLabel.clipsToBounds = true
        self.starLabel.layer.cornerRadius = 8
        self.starLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        self.starLabel.backgroundColor = CustomColor.accentOrange.withAlphaComponent(0.9)

        self.nameLabel.textAlignment = .left
        self.nameLabel.font = UIFont(name: "Recipekorea", size: 12)
    }
}
