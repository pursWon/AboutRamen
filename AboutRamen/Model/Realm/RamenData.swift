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

/// Realm 접근을 한곳으로 모은다.
///
/// 전에는 화면마다 `let realm = try! Realm()`으로 각자 열고 있었다.
/// 디스크가 가득 찼거나 마이그레이션이 어긋나 Realm을 열지 못하면
/// 그 자리에서 앱이 죽는 구조였고, 같은 코드가 일곱 군데에 흩어져 있었다.
enum RamenStorage {
    /// 현재 스레드의 Realm 인스턴스. 열지 못하면 nil.
    /// - NOTE: Realm은 스레드별로 인스턴스를 캐시하므로 매번 호출해도 부담이 적다.
    static var realm: Realm? {
        do {
            return try Realm()
        } catch {
            print("Realm을 열지 못했습니다: \(error)")
            return nil
        }
    }

    /// 저장된 모든 라멘 데이터
    static var allStores: Results<RamenData>? {
        realm?.objects(RamenData.self)
    }

    /// 쓰기 작업을 수행하고 성공 여부를 돌려준다.
    /// 실패해도 앱을 죽이지 않고 호출한 쪽이 사용자에게 알릴 수 있게 한다.
    @discardableResult
    static func write(_ block: (Realm) -> Void) -> Bool {
        guard let realm = realm else { return false }

        do {
            try realm.write { block(realm) }
            return true
        } catch {
            print("Realm 쓰기에 실패했습니다: \(error)")
            return false
        }
    }

    /// 사용자가 아무 흔적도 남기지 않은 데이터를 정리한다.
    /// 홈·검색·마이리스트 세 화면에 같은 코드가 복사돼 있던 것을 여기로 모았다.
    @discardableResult
    static func deleteItemsWithNoUserData() -> Bool {
        guard let stores = allStores else { return false }

        let targets = stores.filter { $0.hasNoUserData }
        guard !targets.isEmpty else { return true }

        return write { realm in
            realm.delete(targets)
        }
    }
}
