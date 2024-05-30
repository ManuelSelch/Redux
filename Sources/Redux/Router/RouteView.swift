import SwiftUI

public struct RouteView<
    Screen: Codable & Equatable & Hashable & Identifiable,
    ScreenContent: View
>: View
{
    @Binding public var routes: [Route<Screen>]
    public let screenContent: (Screen) -> ScreenContent
    
    @State public var path: [Screen] = []
    
    public var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if let screen = path.first {
                    screenContent(screen)
                } else {
                    EmptyView()
                }
            }
            .navigationDestination(for: Screen.self) { screen in
                screenContent(screen)
            }
            
        }
        .onChange(of: routes) {
            path = routes.compactMap { route in
                if case .push(let screen) = route {
                    return screen
                }
                return nil
            }
        }
        
        .sheet(item: Binding<Optional<Screen>>(
            get: {
                routes.compactMap {
                    if case .sheet(let screen) = $0 {
                        return screen
                    }
                    return nil
                }.first
            },
            set: { screen in
                if let screen = screen {
                    routes.removeAll {
                        if case .sheet(let s) = $0, s == screen {
                            return true
                        }
                        return false
                    }
                }
            }
        )) { screen in
            NavigationStack {
                screenContent(screen)
            }
        }
    }
}


import Combine

struct TestFeature: Reducer {
    struct State {
        var routes: [Route<Screen>]
    }
    
    enum Action {
        case router([Route<Screen>])
        case buttonTapped
    }
    
    enum Screen: Codable, Identifiable {
        case home
        case login
        
        var id: Self {self}
    }
    
    struct Dependency {
        
    }
    
    public static func reduce(_ state: inout State, _ action: Action, _ env: Dependency) -> AnyPublisher<Action, Error> {
        switch(action) {
        case .buttonTapped:
            state.routes.append(.push(.home))
        case let .router(routes):
            state.routes = routes
        }
        return Empty().eraseToAnyPublisher()
    }
}

struct TestView: View {
    let store: StoreOf<TestFeature>
    
    var body: some View {
        RouteView(
            routes: Binding(
                get: {store.state.routes},
                set: {store.send(.router($0))}
            )
        ) { screen in
            switch(screen) {
            case .home:
                Text("Home")
            case .login:
                Text("Login")
            }
        }
    }
}


