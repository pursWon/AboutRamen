import Foundation
import RealmSwift

class RamenStore: Object, Decodable {
    var documents = List<Information>()
}

/// API에서 가져오는 데이터 모델
class Information: Object, Decodable {
    @objc dynamic var place_name: String
    @objc dynamic var distance: String
    @objc dynamic var road_address_name: String
    @objc dynamic var place_url: String
    @objc dynamic var phone: String
    @objc dynamic var x: String
    @objc dynamic var y: String
    
    func toRameDataType() -> RamenData {
        // 아직 저장되지 않은 데이터에 사용.
        return RamenData(
            storeName: self.place_name,
            addressName: self.road_address_name,
            x: Double(self.x) ?? 0,
            y: Double(self.y) ?? 0,
            url: self.place_url,
            phone: self.phone,
            rating: 0,
            isGood: false,
            isReviewed: false,
            isFavorite: false)
    }
}
