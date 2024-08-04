import SwiftUI
import NavigationTransitions

public struct RouterView<
    Route: Equatable & Hashable & Identifiable & Codable,
    Content: View
>: View {
    
    var root: Route
    @Binding var stack: [Route]
    
    
    let content: (Route) -> Content
    
    public init(
        root: Route, stack: Binding<[Route]>,
        content: @escaping (Route) -> Content
    ) {
        self.root = root
        self._stack = stack
        self.content = content
    }
    
    public var body: some View {
        NavigationStack(path: $stack) {
            content(root)
                .navigationDestination(for: Route.self) { route in
                    content(route)
                }
        }
        .navigationTransition(.slide)
        
    }
}
