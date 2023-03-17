import Foundation
import RealmSwift

class GoodListData: Object {
    @Persisted var storeName: String
    @Persisted var addressName: String
    @Persisted var x: Double
    @Persisted var y: Double
    @Persisted var rating: Double
    @Persisted var isGoodPressed: Bool
    
    convenience init(storeName: String, addressName: String, x: Double, y: Double, rating: Double, isGoodPressed: Bool) {
        self.init()
        self.storeName = storeName
        self.addressName = addressName
        self.x = x
        self.y = y
        self.rating = rating
        self.isGoodPressed = isGoodPressed
    }
    
    
    // TODO: - DetailVC에서 해당 객체를 사용하지 않고 realm에서 데이터 가져오도록 수정하기
    static var goodList: [GoodListData] = []
}
