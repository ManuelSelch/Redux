@available(iOS 16.0, *)
@available(macOS 12.0, *)
enum ReduxError: Error {
    case unknown(_ message: String)
    case decodeFailed
}
