import XCTest
import ReduxTestStore

final class StoreTests: XCTestCase {
    var store: TestStoreOf<TestFeature>!
    
    override func setUp() {
        store = .init(
            initialState: .init(),
            reducer: TestFeature(),
            middlewares: [
                TestMiddleware().handle
            ]
        )
    }
    
    override func tearDown() async throws {
        await store.finish()
    }
    
    func testMiddlewares() async {
        store.send(.middleware) { _ in }
        await store.receive(.middlewareDispatched) { _ in }
    }
    
    func testLift() async {
        let subStore = store.lift(\.subFeature, TestFeature.Action.subFeature)
        
        subStore.send(.buttonTapped)
        await store.receive(.subFeature(.buttonTapped)) { _ in }
    }
    
    
    func testBinding() async {
        let binding = store.binding(for: \.count, action: TestFeature.Action.countChanged)
        
        binding.wrappedValue = 5
        await store.receive(.countChanged(5)) {
            $0.count = 5
        }
    }
     
    
}
