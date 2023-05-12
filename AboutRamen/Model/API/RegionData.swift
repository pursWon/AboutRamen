import Foundation

func load() -> Data? {
    let fileName: String = ""
    let extensionType: String = "json"
    
    guard let fileLocation = Bundle.main.url(forResource: fileName, withExtension: extensionType) else { return nil }
    
    do {
        let data = try Data(contentsOf: fileLocation)
        
        return data
    } catch {
        return nil
    }
}

struct RegionInformation: Decodable {
    let region: [Region]
}

struct Region: Decodable {
    let city: String
    let local: [Local]
}

struct Local: Decodable {
    let gu: String
    let latitude: Double
    let longtitude: Double
}



