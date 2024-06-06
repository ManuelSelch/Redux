import Foundation
import Combine
import SwiftUI

public typealias StoreOf<R: Reducer> = Store<R.State, R.Action>
public typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?


public class Store<State: Equatable, Action: Equatable>: ObservableObject {
    @Published public private(set) var state: State
    
    var cancellables: Set<AnyCancellable> = []
    var effects: [Action] = []
    
    private let reducer: any Reducer<State, Action>
    private let middlewares:  [Middleware<State, Action>]
    
    var errorAction: ((Error) -> Action)?

    public init(
        initialState: State, 
        reducer: any Reducer<State, Action>,
        middlewares: [Middleware<State, Action>] = [],
        errorAction: ((Error) -> Action)? = nil
    ) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
        self.errorAction = errorAction
    }

    public func send(_ action: Action) {
        let effect = reducer.reduce(&state, action)
 
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
            }, receiveValue: {
                self.effects.append($0)
                self.send($0)
            })
            .store(in: &cancellables)
        
        
        middlewares.forEach { middleware in
            guard let publisher = middleware(state, action) else {
                return
            }
            
            publisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: send)
                .store(in: &cancellables)
        }
    }
    
    
    public func lift<DerivedState: Equatable, ExtractedAction: Equatable>(
        _ deriveState: @escaping (State) -> DerivedState,
        _ embedAction: @escaping (ExtractedAction) -> Action
    ) -> Store<DerivedState, ExtractedAction> {
        
        let derivedStore = Store<DerivedState, ExtractedAction>(
            initialState: deriveState(state),
            reducer: LiftedReducer(parentStore: self, embedAction: embedAction)
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

struct LiftedReducer<ParentState: Equatable, ParentAction: Equatable, DerivedState: Equatable, ExtractedAction: Equatable>: Reducer {
    let parentStore: Store<ParentState, ParentAction>
    let embedAction: (ExtractedAction) -> ParentAction
    
    func reduce(_ state: inout DerivedState, _ action: ExtractedAction) -> AnyPublisher<ExtractedAction, Error> {
        parentStore.send(embedAction(action))
        return .none
    }
}
