import Foundation

struct ReviewListData {
    let storeName: String
    let addressName: String
    var reviewContent: String
    
    static var storeReviews: [ReviewListData] = []
}
