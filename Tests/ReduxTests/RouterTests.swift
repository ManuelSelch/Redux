import XCTest
@testable import Redux
import ReduxTestStore

final class RouterTests: XCTestCase {
    var store: TestStoreOf<TestFeature>!
    
    override func setUp() {
        store = .init(
            initialState: .init(),
            reducer: TestFeature()
        )
    }
    
    override func tearDown() async throws {
        await store.finish()
    }
    
    func testPush() {
        store.send(.push) {
            $0.router.routes = [.settings]
        }
    }
    
    func testUpdateSheet() {
        store.send(.router(.updateSheet(.settings))) {
            $0.router.sheet = .settings
        }
    }
    
    func testUpdateRoutes() {
        store.send(.router(.updateRoutes([.home]))) {
            $0.router.routes = [.home]
        }
    }
    
    func testPresentSheet() {
        store.send(.presentSheet) {
            $0.router.sheet = .settings
        }
    }
    
    func testPresentCover() {
        store.send(.presentCover) {
            $0.router.root = .settings
        }
    }
    
    func testDismiss() {
        store.send(.presentSheet) {
            $0.router.sheet = .settings
        }
        
        store.send(.push) {
            $0.router.routes = [.settings]
        }
        
        store.send(.dismiss) {
            $0.router.sheet = nil
        }
        
        store.send(.dismiss) {
            $0.router.routes = []
        }
    }
    
    func testGoBackToRoot() {
        store.send(.push) {
            $0.router.routes = [.settings]
        }
        
        store.send(.presentSheet) {
            $0.router.sheet = .settings
        }
        
        store.send(.goBackToRoot) {
            $0.router.routes = []
            $0.router.sheet = nil
        }
    }
    
    
}
