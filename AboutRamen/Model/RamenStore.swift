import Foundation
import RealmSwift

class RamenStore: Object, Decodable {
    var documents = List<Information>()
    
    private enum CodingKeys: String, CodingKey {
        case documents = "documents"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let documentsDataDecode = try container.decodeIfPresent([Information].self, forKey: .documents) ?? [Information()]
        
        documents.append(objectsIn: documentsDataDecode)
    }
}

class Information: Object, Decodable {
    @objc dynamic var place_name: String
    @objc dynamic var distance: String
    @objc dynamic var road_address_name: String
    @objc dynamic var phone: String
    
    private enum CodingKeys: String, CodingKey {
        case place_name = "price_name"
        case distance = "distance"
        case road_address_name = "road_address_name"
        case phone = "phone"
    }
}
