import Foundation
import RealmSwift

class MyRamenListData: Object {
    @Persisted var storeName: String
    @Persisted var address: String
    @Persisted var x: Double
    @Persisted var y: Double
    @Persisted var myRamenPressed: Bool

    convenience init(storeName: String, address: String, x: Double, y: Double, myRamenPressed: Bool) {
        self.init()
        self.storeName = storeName
        self.address = address
        self.x = x
        self.y = y
        self.myRamenPressed = myRamenPressed
    }

    static var myRamenList: [MyRamenListData] = []
}

