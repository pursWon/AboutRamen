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
        let attributes = [NSAttributedString.Key.font: AppFont.title(13)]

        self.navigationItem.backBarButtonItem = backButton
        // 검정 고정 대신 다크 모드를 따라가는 토큰을 쓴다
        self.navigationItem.backBarButtonItem?.tintColor = CustomColor.ink
        backButton.setTitleTextAttributes(attributes, for: .normal)
    }
}
