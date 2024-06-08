import XCTest
import ReduxTestStore


final class ReducerTests: XCTestCase {
    var store: TestStoreOf<TestFeature>!
    
    override func setUp() {
        store = .init(initialState: .init(), reducer: TestFeature())
    }
    
    override func tearDown() async throws {
        await store.finish()
    }
    
    func testAction() {
        store.send(.buttonTapped) {
            $0.count = 2
        }
    }
    
    func testMergeActions() async {
        store.send(.merge) {  _ in }
        
        await store.receive([.buttonTapped, .buttonTapped]) {
            $0.count = 3
        }
    }
    
    func testEffect() async {
        store.send(.run) { _ in }
        
        await store.receive(.buttonTapped) {
            $0.count = 2
        }
    }
    
    
}
