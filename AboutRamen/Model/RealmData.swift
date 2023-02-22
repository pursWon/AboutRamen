import Foundation
import RealmSwift

class RealmData: Object {
    @Persisted var storeName: String
    @Persisted var rating: Double
    @Persisted var isGoodPressed: Bool
    @Persisted var reviewContent: String
    @Persisted var isMyRamenPressed: Bool
    
    convenience init(storeName: String, isGoodPressed: Bool, rating: Double, reviewContent: String, isMyRamenPressed: Bool) {
        self.init()
        self.storeName = storeName
        self.rating = rating
        self.isGoodPressed = isGoodPressed
        self.reviewContent = reviewContent
        self.isMyRamenPressed = isMyRamenPressed
    }
}
