import UIKit

extension ReviewViewController {
    func listAlert() {
        let alert = UIAlertController(title: "해당 가게가 이미 리스트에 존재합니다.", message: "", preferredStyle: UIAlertController.Style.alert)
        present(alert, animated: true, completion: nil)
        let cancel = UIAlertAction(title: "닫기", style: .default)
        alert.addAction(cancel)
    }
}

