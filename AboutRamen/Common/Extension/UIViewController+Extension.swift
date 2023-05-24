import UIKit
import CoreLocation

extension UIViewController {
    /// 현재 위치로부터 가게까지의 거리를 구하는 함수
    func getDistance(from currentLocation: CLLocation?, to targetLocation: CLLocation?) -> String {
        guard let currentLocation = currentLocation, let targetLocation = targetLocation else { return "- km" }
        return "\(String(format: "%.2f", targetLocation.distance(from: currentLocation) / 1000)) km"
    }
    
    /// back button을 지정한 title로 커스텀하는 함수
    func setCustomBackButton(title: String) {
        let backButton = UIBarButtonItem(title: title, style: .plain, target: self, action: nil)
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Recipekorea", size: 14) ?? UIFont()]
        
        self.navigationItem.backBarButtonItem = backButton
        self.navigationItem.backBarButtonItem?.tintColor = .black
        backButton.setTitleTextAttributes(attributes, for: .normal)
    }
}
