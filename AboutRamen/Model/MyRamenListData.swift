import Foundation
import RealmSwift

class MyRamenListData: Object {
    @Persisted var storeName: String
    @Persisted var address: String
    @Persisted var x: Double
    @Persisted var y: Double
    @Persisted var url: String
    @Persisted var phone: String
    @Persisted var myRamenPressed: Bool

    convenience init(storeName: String, address: String, x: Double, y: Double, url: String, phone: String, myRamenPressed: Bool) {
        self.init()
        self.storeName = storeName
        self.address = address
        self.x = x
        self.y = y
        self.url = url
        self.phone = phone
        self.myRamenPressed = myRamenPressed
    }
}

