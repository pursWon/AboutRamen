import Foundation
import RealmSwift

class RamenStore: Object, Decodable {
    var documents = List<Information>()
}

class Information: Object, Decodable {
    @objc dynamic var place_name: String
    @objc dynamic var distance: String
    @objc dynamic var road_address_name: String
    @objc dynamic var phone: String
}
