import Foundation
import Combine


@available(iOS 16.0, *)
public typealias Reducer<State, Action, Dependencies> = (inout State, Action, Dependencies) -> AnyPublisher<Action, Error>?

@available(iOS 16.0, *)
public typealias Middleware<State, Action, Dependencies> = (State, Action, Dependencies) -> AnyPublisher<Action, Never>?
 
@available(iOS 16.0, *)
public class Store<State, Action, Dependencies>: ObservableObject {
    @Published public private(set) var state: State
    
    private var cancellables: Set<AnyCancellable> = []
    
    public let dependencies: Dependencies
    private let reducer: Reducer<State, Action, Dependencies>
    private let middlewares:  [Middleware<State, Action, Dependencies>]

    public init(
        initialState: State, 
        reducer: @escaping Reducer<State, Action, Dependencies>,
        dependencies: Dependencies,
        middlewares: [Middleware<State, Action, Dependencies>] = []
    ) {
        self.state = initialState
        self.reducer = reducer
        self.dependencies = dependencies
        self.middlewares = middlewares
    }

    public func send(_ action: Action) {
        handleLog(action)
        
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
                        self.handleError(e)
                
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
    
    public func handleError(_ error: Error) {
        
    }
    
    public func handleLog(_ action: Action) {
       
    }
}
