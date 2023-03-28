import UIKit

extension UIViewController {
    enum AlertStyle {
        case oneButton
        case twoButton
    }
    
    func showAlert(title: String, message: String? = nil, alertStyle: AlertStyle) {
        let alert = UIAlertController(title: title, message: message ?? "", preferredStyle: UIAlertController.Style.alert)
        
        if alertStyle == .oneButton {
        let cancel = UIAlertAction(title: "닫기", style: .default)
        alert.addAction(cancel)
        } else {
            let ok = UIAlertAction(title: "예", style: .default, handler: { action in
                self.navigationController?.popViewController(animated: true)
            })
            ok.setValue(UIColor.blue, forKey: "titleTextColor")
            
            let no = UIAlertAction(title: "아니오", style: .default)
            no.setValue(UIColor.systemRed, forKey: "titleTextColor")
            alert.addAction(ok)
            alert.addAction(no)
        }
        
        present(alert, animated: true, completion: nil)
    }
}
