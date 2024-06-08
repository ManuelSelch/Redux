import XCTest
import Moya
import Redux

final class ServiceTests: XCTestCase {
    let provider = MoyaProvider<TestAPI>(
        stubClosure: MoyaProvider.immediatelyStub
    )
    
    func testRequest() async throws {
        let data: TestModel = try await Service.request(provider, .fetch)
        
        XCTAssertEqual(TestModel.sample, data)
    }
}


