import Foundation

struct ReviewListData {
    let storeName: String
    let addressName: String
    var reviewContent: String
    
}

struct DataStorage {
    static var goodList: [RamenListData] = []
    static var badList: [RamenListData] = []
    static var myRamenList: [RamenListData] = []
    static var storeReviews: [ReviewListData] = []
}
