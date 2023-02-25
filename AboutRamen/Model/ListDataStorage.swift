import Foundation
import RealmSwift

struct AllDataStorage {
    static var allRamenData: List<Information>?
}

struct ListDataStorage: Hashable {
    let name: String
    let address: String
    let rating: Double
    
    static var goodList: Set<ListDataStorage> = Set<ListDataStorage>()
    static var myRamenList: Set<ListDataStorage> = Set<ListDataStorage>()
    static var reviewList: Set<ListDataStorage> = Set<ListDataStorage>()
}
