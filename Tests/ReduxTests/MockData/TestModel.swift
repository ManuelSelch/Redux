import Foundation

struct TestModel: Codable, Equatable {
    var name: String
}

extension TestModel {
    static let sample = TestModel(name: "Sample")
}
