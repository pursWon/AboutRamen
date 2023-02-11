import Foundation

struct BadListData: Hashable {
    let storeName: String
    let addressName: String
    let rating: String
    let pressed: Bool
    let distance: String
    let phone: String
    
    static var badListArray: [BadListData] = []
}
