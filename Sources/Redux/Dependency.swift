import Foundation

public protocol DependencyKey {
    /// The associated type representing the type of the dependency injection key's value.
    associatedtype Value

    /// The default value for the dependency injection key.
    static var liveValue: Value { get set }
    static var mockValue: Value { get set }
    
}

public extension DependencyKey {
    public static var mockValue: Value { Self.liveValue }
}

/// Provides access to injected dependencies.
public struct DependencyValues {
    public enum Mode {
        case live
        case mock
    }
    
    public static var mode: Mode = .live
    
    /// This is only used as an accessor to the computed properties within extensions of `DependencyKey`.
    private static var current = DependencyValues()
    
    /// A static subscript for updating the `currentValue` of `DependencyKey` instances.
    public static subscript<K>(key: K.Type) -> K.Value where K : DependencyKey {
        get {
            switch(mode) {
            case .live:
                return key.liveValue
            case .mock:
                return key.mockValue
            }
        }
        
        set {
            switch(mode) {
            case .live:
                key.liveValue = newValue
            case .mock:
                key.mockValue = newValue
            }
        }
    }
    
    /// A static subscript accessor for updating and references dependencies directly.
    public static subscript<T>(_ keyPath: WritableKeyPath<DependencyValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}


@propertyWrapper
public struct Dependency<T> {
    private let keyPath: WritableKeyPath<DependencyValues, T>
    public var wrappedValue: T {
        get { DependencyValues[keyPath] }
        set { DependencyValues[keyPath] = newValue }
    }
    
    public init(_ keyPath: WritableKeyPath<DependencyValues, T>) {
        self.keyPath = keyPath
    }
}
