import Foundation
import Combine
import XCTest

@testable import Redux

struct TestFeature: Reducer {
    struct State: Equatable {
        var count = 1
    }
    
    enum Action {
        case buttonTapped
    }
    
    func reduce(_ state: inout State, _ action: Action) -> AnyPublisher<Action, Error> {
        return .none
    }
}


class TestClass: XCTestCase {
    var store: TestStoreOf<TestFeature>!
    
    override func setUp() {
        store = .init(initialState: .init(), reducer: TestFeature())
    }
    
    func testReducer() {
        store.send(.buttonTapped) {
            $0.count = 2
        }
    }
}
