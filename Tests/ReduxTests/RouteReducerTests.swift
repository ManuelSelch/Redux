import XCTest
@testable import Redux

enum TestRoute: Codable {
    case home
    case detail1
    case detail2
    case detail3
}

final class RouteReducerTests: XCTestCase {
    var store: StoreOf<RouteModule<TestRoute>>!
    
    override func setUp() {
        store = .init(initialState: .init(), reducer: RouteModule.reduce, dependencies: .init())
    }
    
    func testStack() throws {
        store.send(.push(.detail1))
        XCTAssertEqual([.detail1], store.state.routes)
        
        store.send(.push(.detail2))
        XCTAssertEqual([.detail1, .detail2], store.state.routes)
        
        store.send(.pop)
        XCTAssertEqual([.detail1], store.state.routes)
        
        store.send(.set([.home]))
        XCTAssertEqual([.home], store.state.routes)
    }
    
    func testSheet() throws {
        store.send(.presentSheet(.detail3))
        XCTAssertEqual(.detail3, store.state.sheet)
        
        store.send(.dismissSheet)
        XCTAssertEqual(nil, store.state.sheet)
    }
}
