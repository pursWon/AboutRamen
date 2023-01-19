import Foundation

struct RamenStore: Decodable {
    let documents: [Information]
}

struct Information: Decodable {
    let place_name: String
    let distance: String
    let road_address_name: String
    let phone: String
}
