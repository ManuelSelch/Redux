import Foundation
import Combine

@available(iOS 16.0, *)
@available(macOS 12.0, *)
public typealias StoreOf<R: Reducer> = Store<R.State, R.Action, R.Dependency>

@available(iOS 16.0, *)
@available(macOS 12.0, *)
public protocol Reducer<State, Action, Dependency> {
    associatedtype State
    associatedtype Action
    associatedtype Dependency
    
    static func reduce(_ state: inout State, _ action: Action, _ env: Dependency) -> AnyPublisher<Action, Error>
}

@available(iOS 16.0, *)
@available(macOS 12.0, *)
public extension Reducer {
    static func just<T>(_ event: T) -> AnyPublisher<T, Error> {
        return Just(event)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
