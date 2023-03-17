import Foundation
import RealmSwift

class ReviewListData: Object {
    @Persisted var storeName: String
    @Persisted var addressName: String
    @Persisted var reviewContent: String
    
    convenience init(storeName: String, addressName: String, reviewContent: String) {
        self.init()
        self.storeName = storeName
        self.addressName = addressName
        self.reviewContent = reviewContent
    }
}

