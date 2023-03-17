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
    // TODO: - DetailVC에서 해당 객체를 사용하지 않고 realm에서 데이터 가져오도록 수정하기
    static var myRamenList: [MyRamenListData] = []
}

