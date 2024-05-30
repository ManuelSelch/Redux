import Foundation
import Combine

public protocol Reducer<State, Action, Dependency> {
    associatedtype State
    associatedtype Action
    associatedtype Dependency
    
    static func reduce(_ state: inout State, _ action: Action, _ env: Dependency) -> AnyPublisher<Action, Error>
}

public extension Reducer {
    static func just<T>(_ event: T) -> AnyPublisher<T, Error> {
        return Just(event)
            .setFailureType(to: Error.self)
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
        return AnyPublisher.merge(publishers)
    }
    
    static var none: AnyPublisher<Output, Failure> {
        Empty()
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }
}
