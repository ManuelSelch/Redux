import Foundation
import Combine

@available(iOS 16.0, *)
public typealias Reducer<State, Action> = (inout State, Action) -> AnyPublisher<Action, Error>?

@available(iOS 16.0, *)
public typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?


 
@available(iOS 16.0, *)
public class Store<State, Action>: ObservableObject {
    @Published public private(set) var state: State
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let reducer: Reducer<State, Action>
    private var middlewares:  [Middleware<State, Action>]

    public init(
        initialState: State, 
        reducer: @escaping Reducer<State, Action>,
        middlewares: [Middleware<State, Action>] = []
    ) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
    }

    public func send(_ action: Action) {
        handleLog(action)
        
        guard let effect = reducer(&state, action) else {
            return
        }
 
        effect
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let e):
                        self.handleError(e)
                
                }
            }, receiveValue: send)
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
    
    
    public func lift<DerivedState: Equatable, ExtractedAction>(
        _ deriveState: @escaping (State) -> DerivedState,
        _ embedAction: @escaping (ExtractedAction) -> Action
    ) -> Store<DerivedState, ExtractedAction> {
        
        let derivedStore = Store<DerivedState, ExtractedAction>(
            initialState: deriveState(state),
            reducer: { derivedState, action  in
                self.send(embedAction(action))
                return Empty().eraseToAnyPublisher()
            }
        )
        
        $state
            .map(deriveState)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &derivedStore.$state)
        
        return derivedStore
    }
    
    public func handleError(_ error: Error) {
        
    }
    
    public func handleLog(_ action: Action) {
       
    }
}
