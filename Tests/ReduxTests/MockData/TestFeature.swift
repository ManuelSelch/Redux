import Redux
import Combine

struct TestFeature: Reducer {
    struct State: Equatable {
        var count = 1
        
        var subFeature: SubFeature.State = .init()
        
        var router: RouterFeature<Route>.State = .init(root: .home)
    }
    
    enum Action: Equatable {
        case buttonTapped
        case countChanged(Int)
        case run
        case merge
        case middleware
        case middlewareDispatched
        
        case presentSheet
        case presentCover
        case dismiss
        case goBackToRoot
        case push
        
        case subFeature(SubFeature.Action)
        case router(RouterFeature<Route>.Action)
    }
    
    enum Route: Equatable, Identifiable, Codable {
        case home
        case settings
        
        var id: Self {self}
    }
    func reduce(_ state: inout State, _ action: Action) -> Effect<Action> {
        switch(action) {
        case .buttonTapped:
            state.count += 1
        case let .countChanged(count):
            state.count = count
        case .merge:
            return .merge([
                .send(.buttonTapped),
                .send(.buttonTapped)
            ])
        case .run:
            return .run { send in
                // try? await Task.sleep(nanoseconds: 500_00_00)
                send(.success(.buttonTapped))
            }
        case .middleware:
            break
        case .middlewareDispatched:
            break
            
        case .presentSheet:
            state.router.presentSheet(.settings)
        case .presentCover:
            state.router.presentCover(.settings)
        case .dismiss:
            state.router.dismiss()
        case .goBackToRoot:
            state.router.goBackToRoot()
        case .push:
            state.router.push(.settings)
            
        case let .subFeature(action):
            return SubFeature().reduce(&state.subFeature, action)
                .map { .subFeature($0) }
                .eraseToAnyPublisher()
            
        case let .router(action):
            return RouterFeature<Route>().reduce(&state.router, action)
                .map { .router($0) }
                .eraseToAnyPublisher()
        }
        
        return .none
    }
}

struct TestMiddleware {
    func handle(_ state: TestFeature.State, _ action: TestFeature.Action) -> AnyPublisher<TestFeature.Action, Never> {
        
        switch(action) {
        case .middleware:
            return .send(.middlewareDispatched)
        default: break
        }
        
        return .none
    }
}
