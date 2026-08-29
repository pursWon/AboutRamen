import UIKit
import Kingfisher

/// 홈 - 라면 정보 셀
class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ramenView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var ramenImageView: UIImageView!

    func cellConfigure() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // 진한 테두리 대신 옅은 그림자로 층을 만든다
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.masksToBounds = false

        ramenView.backgroundColor = CustomColor.surface
        ramenView.layer.cornerRadius = 16
        ramenView.layer.masksToBounds = true
        ramenView.layer.borderWidth = 1
        ramenView.layer.borderColor = CustomColor.hairline.cgColor

        distanceLabel.clipsToBounds = true
        distanceLabel.layer.cornerRadius = 8
        distanceLabel.font = AppFont.body(11)
        distanceLabel.textColor = .white
        distanceLabel.backgroundColor = UIColor.black.withAlphaComponent(0.45)

        starLabel.clipsToBounds = true
        starLabel.layer.cornerRadius = 8
        starLabel.font = AppFont.body(11)
        starLabel.textColor = .white
        starLabel.backgroundColor = CustomColor.accent

        nameLabel.textAlignment = .left
        nameLabel.font = AppFont.cardName
        nameLabel.textColor = CustomColor.ink
    }

    /// 별점 배지 표시. 매겨진 값이 없으면 배지 자체를 숨긴다.
    func setRating(_ rating: Double?) {
        guard let rating = rating, rating > 0 else {
            starLabel.isHidden = true
            return
        }

        starLabel.isHidden = false
        starLabel.text = " ★ \(String(format: "%.1f", rating)) "
    }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)

        // cgColor는 다이나믹 컬러를 따라가지 않으므로 테마가 바뀌면 다시 지정한다
        if traitCollection.hasDifferentColorAppearance(comparedTo: previous) {
            ramenView.layer.borderColor = CustomColor.hairline.cgColor
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        ramenImageView.kf.cancelDownloadTask()
        ramenImageView.image = nil
        starLabel.isHidden = false
    }
}
