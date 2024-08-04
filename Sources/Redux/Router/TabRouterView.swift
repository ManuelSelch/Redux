import SwiftUI

public struct TabRouterView<
    TabRoute: Identifiable & Codable & Equatable & Hashable & CaseIterable,
    Content: View,
    Label: View
>: View where TabRoute.AllCases: RandomAccessCollection {
    @Binding var tab: TabRoute
    
    let content: (TabRoute) -> Content
    let label: (TabRoute) -> Label
    
    public init(tab: Binding<TabRoute>, content: @escaping (TabRoute) -> Content, label: @escaping (TabRoute) -> Label) {
        self._tab = tab
        self.content = content
        self.label = label
    }
    
    public var body: some View {
        TabView(selection: $tab) {
            ForEach(TabRoute.allCases) { tab in
                content(tab)
                    .tabItem {
                        label(tab)
                    }
                    .tag(tab)
            }
        }
    }
}

