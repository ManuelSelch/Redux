import Foundation
import Combine
import SwiftUI

public typealias StoreOf<R: Reducer> = Store<R.State, R.Action, R.Dependency>

public typealias Middleware<State, Action, Dependencies> = (State, Action, Dependencies) -> AnyPublisher<Action, Never>?

public class Store<State, Action, Dependencies>: ObservableObject {
    @Published public private(set) var state: State
    
    private var cancellables: Set<AnyCancellable> = []
    
    public let dependencies: Dependencies
    private let reducer: (inout State, Action, Dependencies) -> AnyPublisher<Action, Error>?
    private let middlewares:  [Middleware<State, Action, Dependencies>]
    
    var errorAction: ((Error) -> Action)?

    public init(
        initialState: State, 
        reducer: @escaping(inout State, Action, Dependencies) -> AnyPublisher<Action, Error>,
        dependencies: Dependencies,
        middlewares: [Middleware<State, Action, Dependencies>] = [],
        errorAction: ((Error) -> Action)? = nil
    ) {
        self.state = initialState
        self.reducer = reducer
        self.dependencies = dependencies
        self.middlewares = middlewares
        self.errorAction = errorAction
    }

    public func send(_ action: Action) {
        guard let effect = reducer(&state, action, dependencies) else {
            return
        }
 
        effect
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let e):
                        if let errorAction = self.errorAction {
                            self.send(errorAction(e))
                        }
                }
            }, receiveValue: send)
            .store(in: &cancellables)
        
        
        middlewares.forEach { middleware in
            
            guard let publisher = middleware(state, action, dependencies) else {
                return
            }
            
            publisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: send)
                .store(in: &cancellables)
        }
    }
    
    
    public func lift<DerivedState: Equatable, ExtractedAction, DerivedDependencies>(
        _ deriveState: @escaping (State) -> DerivedState,
        _ embedAction: @escaping (ExtractedAction) -> Action,
        _ derivedDependencies: DerivedDependencies
    ) -> Store<DerivedState, ExtractedAction, DerivedDependencies> {
        
        let derivedStore = Store<DerivedState, ExtractedAction, DerivedDependencies>(
            initialState: deriveState(state),
            reducer: { derivedState, action, dependencies  in
                self.send(embedAction(action))
                return Empty().eraseToAnyPublisher()
            },
            dependencies: derivedDependencies
        )
        
        $state
            .map(deriveState)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &derivedStore.$state)
        
        return derivedStore
    }
    
  
    public func binding<Value>(
        for keyPath: KeyPath<State, Value>,
        action: @escaping (Value) -> Action
    ) -> Binding<Value> {
        return Binding(
            get: { self.state[keyPath: keyPath] },
            set: { self.send(action($0)) }
        )
    }
}
