import Foundation

struct GoodListData: Hashable {
    let storeName: String
    let addressName: String
    let rating: String
    let pressed: Bool
    let distance: String
    let phone: String
    
    static var goodListArray: [GoodListData] = []
}
