import Foundation
import Combine

public protocol Reducer<State, Action> {
    associatedtype State: Equatable
    associatedtype Action
    
    func reduce(_ state: inout State, _ action: Action) -> AnyPublisher<Action, Error>
}



public extension AnyPublisher {
    static func send(_ action: Output) -> AnyPublisher<Output, Failure> {
        return Just(action)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }
    
    static func merge(_ publishers: [AnyPublisher<Output, Failure>]) -> AnyPublisher<Output, Failure> {
        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }
    
    static var none: AnyPublisher<Output, Failure> {
        Empty()
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }
    
    static func run( 
        _ operation: @escaping (
            (Result<Output, Failure>) -> Void
        ) async -> Void
    ) -> AnyPublisher<Output, Failure>
    {
        return Future<Output, Failure> { promise in
            Task {
                await operation(promise)
            }
        }
        .eraseToAnyPublisher()
    }
}
