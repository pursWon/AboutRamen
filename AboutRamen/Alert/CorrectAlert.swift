import UIKit

extension ReviewViewController {
    func correctAlert() {
        let alert = UIAlertController(title: "수정하시겠습니까?", message: "", preferredStyle: UIAlertController.Style.alert)
        present(alert, animated: true, completion: nil)
        let ok = UIAlertAction(title: "예", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        ok.setValue(UIColor.blue, forKey: "titleTextColor")
        let no = UIAlertAction(title: "아니오", style: .default)
        no.setValue(UIColor.systemRed, forKey: "titleTextColor")
        alert.addAction(ok)
        alert.addAction(no)
    }
}
