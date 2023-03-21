import Foundation

extension Bundle {
    var apiKey: String {
        guard let file = self.path(forResource: "RamenInfo", ofType: "plist") else { return ""}
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["API_KEY"] as? String else { fatalError("AboutRamen.plist에 API_KEY 설정을 해주세요") }
        
        return key
    }
}
