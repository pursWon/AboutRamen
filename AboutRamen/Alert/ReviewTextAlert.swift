import UIKit

extension ReviewViewController {
    func alert() {
        let alert = UIAlertController(title: "리뷰 항목이 비어있습니다.", message: "", preferredStyle: UIAlertController.Style.alert)
        present(alert, animated: true, completion: nil)
        let cancel = UIAlertAction(title: "닫기", style: .default)
        alert.addAction(cancel)
    }
}
