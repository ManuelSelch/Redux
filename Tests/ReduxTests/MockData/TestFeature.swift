import Redux
import Combine

struct TestFeature: Reducer {
    struct State: Equatable {
        var count = 1
        
        var subFeature: SubFeature.State = .init(sub: .init())
        
        var router: AppRouterFeature<Route, TabRoute>.State = .init(screen: .root, routers: [
            .root: .init(root: .home),
            .tab(.tab1): .init(root: .settings),
            .tab(.tab2): .init(root: .settings)
        ])
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
        case router(AppRouterFeature<Route, TabRoute>.Action)
    }
    
    enum Route: Equatable, Identifiable, Codable {
        case home
        case settings
        
        var id: Self {self}
    }
    
    enum TabRoute: Equatable, Hashable, Codable, Identifiable, CaseIterable {
        case tab1
        case tab2
        
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
            state.router.presentRootScreen(.settings)
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
            return AppRouterFeature<Route, TabRoute>().reduce(&state.router, action)
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
