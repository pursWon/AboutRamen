import Foundation
import RealmSwift

/// 렘에 저장되는 라면 데이터 모델
class RamenData: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var storeName: String
    @Persisted var addressName: String
    @Persisted var x: Double
    @Persisted var y: Double
    @Persisted var rating: Double
    @Persisted var url: String
    @Persisted var phone: String
    @Persisted var isGood: Bool
    @Persisted var isFavorite: Bool
    @Persisted var isReviewed: Bool
    @Persisted var reviewContent: String?

    /// 사용자가 남긴 흔적이 하나도 없는 데이터인지 여부.
    /// - NOTE: rating을 조건에 넣지 않으면 "별점만 매긴" 가게가 정리 대상으로 잡혀 삭제된다.
    var hasNoUserData: Bool {
        !isGood && !isReviewed && !isFavorite && rating == 0
    }

    convenience init(storeName: String, addressName: String, x: Double, y: Double, url: String, phone: String, rating: Double, isGood: Bool, isReviewed: Bool, isFavorite: Bool, reviewContent: String? = nil) {
        self.init()
        
        self.storeName = storeName
        self.addressName = addressName
        self.x = x
        self.y = y
        self.url = url
        self.rating = rating
        self.phone = phone
        self.isGood = isGood
        self.isReviewed = isReviewed
        self.isFavorite = isFavorite
        self.reviewContent = reviewContent
    }
}
