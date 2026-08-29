import Foundation
import CoreLocation

func load() -> Data? {
    let fileName: String = "RegionInformation"
    let extensionType: String = "json"

    guard let fileLocation = Bundle.main.url(forResource: fileName, withExtension: extensionType) else { return nil }

    do {
        let data = try Data(contentsOf: fileLocation)

        return data
    } catch {
        return nil
    }
}

struct RegionInformation: Decodable {
    let region: [Region]
}

struct Region: Decodable {
    let city: String
    let local: [Local]
}

struct Local: Decodable {
    let gu: String
    let latitude: Double
    let longtitude: Double
}

/// 지역 정보와 "지금 보고 있는 지역"을 앱 전체가 공유하는 저장소.
/// 전에는 파일 최상단의 전역 변수 `region`이 이 역할을 했는데,
/// 네임스페이스를 오염시키고 홈/검색 탭이 서로 다른 지역을 보는 원인이 되었다.
final class RegionStore {
    static let shared = RegionStore()

    /// 선택된 지역이 바뀌었음을 알리는 알림 (홈·검색 탭이 함께 구독한다)
    static let didChangeNotification = Notification.Name("RegionStoreDidChange")

    /// RegionInformation.json 파싱 결과
    let information: RegionInformation?

    /// 현재 기준 좌표. GPS를 쓰는 중이면 GPS 좌표, 지역을 직접 골랐으면 그 좌표.
    private(set) var selectedLocation: CLLocation?
    /// 화면에 표시할 지역 이름 ("현재 위치 주변" 또는 "서울시 강남구")
    private(set) var selectedTitle: String?

    private init() {
        guard let data = load() else {
            information = nil
            return
        }

        information = try? JSONDecoder().decode(RegionInformation.self, from: data)
    }

    /// JSON의 첫 번째 지역 (GPS를 못 받았을 때의 기본값)
    var defaultLocation: CLLocation? {
        guard let first = information?.region.first?.local.first else { return nil }
        return CLLocation(latitude: first.latitude, longitude: first.longtitude)
    }

    var defaultTitle: String? {
        guard let region = information?.region.first, let local = region.local.first else { return nil }
        return "\(region.city) \(local.gu)"
    }

    /// 지역이 바뀌었음을 저장하고 구독 중인 화면들에 알린다
    func update(location: CLLocation, title: String) {
        selectedLocation = location
        selectedTitle = title

        NotificationCenter.default.post(name: RegionStore.didChangeNotification, object: nil)
    }
}
