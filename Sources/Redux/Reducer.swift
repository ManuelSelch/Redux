import Foundation
import Combine

public protocol Reducer<State, Action> {
    associatedtype State: Equatable
    associatedtype Action: Equatable
    
    func reduce(_ state: inout State, _ action: Action) -> Effect<Action>
}

public extension Reducer {
    func lift<Parent>(_ state: inout State, _ action: Action, toParent: @escaping (Action) -> Parent) -> Effect<Parent> {
        return reduce(&state, action)
            .map(toParent)
            .eraseToAnyPublisher()
    }
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
