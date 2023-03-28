import Foundation

struct RamenImage: Decodable {
    let documents: [Image]
}

struct Image: Decodable {
    let image_url: String
}
