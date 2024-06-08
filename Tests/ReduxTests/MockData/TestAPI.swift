import Foundation
import Moya

enum TestAPI {
    case fetch
}

extension TestAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.manuelselch.de")!
    }
    
    var path: String { "/fetch" }
    
    var method: Moya.Method { .get }
    
    var task: Moya.Task { .requestPlain }
    
    var headers: [String : String]? { [:] }
    
    var sampleData: Data {
        try! JSONEncoder().encode(TestModel.sample)
    }
}
