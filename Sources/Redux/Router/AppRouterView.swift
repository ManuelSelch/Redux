import SwiftUI

public struct AppRouterView<
    Route: Equatable & Hashable & Identifiable & Codable,
    TabRoute: Equatable & Hashable & Codable & Identifiable & CaseIterable,
    Header: View,
    Content: View,
    Label: View
>: View where TabRoute.AllCases: RandomAccessCollection {
    @ObservedObject var store: StoreOf<AppRouterFeature<Route, TabRoute>>
    
    let header: () -> Header
    let content: (Route) -> Content
    let label: (TabRoute) -> Label
    
    public init(store: StoreOf<AppRouterFeature<Route, TabRoute>>, header: @escaping () -> Header, content: @escaping (Route) -> Content, label: @escaping (TabRoute) -> Label) {
        self.store = store
        self.header = header
        self.content = content
        self.label = label
    }
    
    
    public var body: some View {
        ZStack {
            
            VStack {
                header()
                
                switch(store.state.screen) {
                case .root:
                    RouterView(
                        root: store.state.currentRouter.root,
                        stack: store.binding(for: \.currentRouter.stack, action: AppRouterFeature.Action.updateRoutes)
                    ) { route in
                        content(route)
                    }
                        
                    
                case let .tab(currentTab):
                    TabRouterView(
                        tab: Binding(
                            get: {currentTab},
                            set: {store.send(.updateScreen(.tab($0)))}
                        ),
                        content: { tab in
                            RouterView(
                                root: store.state.currentRouter.root,
                                stack: Binding(get: { store.state.routers[.tab(tab)]!.stack }, set: { store.send(.updateRoutes($0)) })
                            ) { route in
                                content(route)
                            }
                        },
                        label: { route in
                            label(route)
                        }
                    )
                }
                
                
                
               
            }
            
        }
        .sheet(item: Binding(
            get: {
                store.state.sheet?.root
            }, set: {
                store.send(.updateSheet($0))
            }
        ))
        { route in
            RouterView(
                root: route,
                stack: Binding(
                    get: { store.state.sheet?.stack ?? [] },
                    set: { store.send(.updateRoutes($0)) }
                )
            ) { route in
                content(route)
            }
        }
    }
}

