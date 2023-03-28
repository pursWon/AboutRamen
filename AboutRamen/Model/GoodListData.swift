import Foundation
import RealmSwift

class GoodListData: Object {
    @Persisted var storeName: String
    @Persisted var addressName: String
    @Persisted var x: Double
    @Persisted var y: Double
    @Persisted var rating: Double
    @Persisted var url: String
    @Persisted var phone: String
    @Persisted var isGoodPressed: Bool
    
    convenience init(storeName: String, addressName: String, x: Double, y: Double, rating: Double, url: String, phone: String, isGoodPressed: Bool) {
        self.init()
        self.storeName = storeName
        self.addressName = addressName
        self.x = x
        self.y = y
        self.rating = rating
        self.url = url
        self.phone = phone
        self.isGoodPressed = isGoodPressed
    }
}
