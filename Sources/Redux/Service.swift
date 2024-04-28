import Foundation
import Combine
import Moya

public protocol IService {
     
}

public extension IService {
    func just<T>(_ event: T) -> AnyPublisher<T, Error> {
        return Just(event)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func request<Response: Decodable, TargetType>(_ provider: MoyaProvider<TargetType>, _ method: TargetType) -> AnyPublisher<Response, Error> {
        return Future<Response, Error> { promise in
            provider.request(method){ result in
                switch result {
                case .success(let response):
                    if let data = try? JSONDecoder().decode(Response.self, from: response.data) {
                        promise(.success(data))
                    }else {
                        if let string = String(data: response.data, encoding: .utf8) {
                            promise(.failure(ReduxError.unknown(method.path + " -> " + string)))
                        }else{
                            promise(.failure(ReduxError.decodeFailed))
                        }
                    }
                case .failure(let error):
                    promise(.failure(ReduxError.unknown(method.path + " -> " + error.localizedDescription)))
                }
            }
        }.eraseToAnyPublisher()
    }
}
