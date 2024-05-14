import Foundation
import Combine
import Moya

@available(iOS 16.0, *)
@available(macOS 12.0, *)
public protocol IService {
     
}

@available(iOS 16.0, *)
@available(macOS 12.0, *)
public extension IService {
    func just<T>(_ event: T) -> AnyPublisher<T, Error> {
        return Just(event)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func request<Response: Decodable, TargetType>(_ provider: MoyaProvider<TargetType>, _ method: TargetType) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(method){ result in
                switch result {
                case .success(let response):
                    if let data = try? JSONDecoder().decode(Response.self, from: response.data) {
                        continuation.resume(returning: data)
                    }else {
                        if let string = String(data: response.data, encoding: .utf8) {
                            continuation.resume(throwing: ReduxError.unknown(method.path + " -> " + string))
                        }else{
                            continuation.resume(throwing: ReduxError.decodeFailed)
                        }
                    }
                case .failure(let error):
                    continuation.resume(throwing: ReduxError.unknown(method.path + " -> " + error.localizedDescription))
                }
            }
        }
    }
}
