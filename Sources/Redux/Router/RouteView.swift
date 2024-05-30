import SwiftUI

public struct RouterView<
    Route: Equatable & Hashable & Identifiable,
    Content: View
>: View {
    @ObservedObject var store: StoreOf<RouterFeature<Route>>
    // Holds our root view content
    private let content: (Route) -> Content
    
    public init(
        store: StoreOf<RouterFeature<Route>>,
        content: @escaping (Route) -> Content)
    {
        self.store = store
        self.content = content
    }
    
    public var body: some View {
        NavigationStack(path: Binding(
            get: { store.state.routes },
            set: { store.send(.updateRoutes($0)) }
        )) {
            content(store.state.root)
                .navigationDestination(for: Route.self) { route in
                    content(route)
                }
        }
        .sheet(item: Binding(
            get: { store.state.sheet },
            set: { store.send(.updateSheet($0)) }
        )) { route in
            content(route)
        }
    }
}
