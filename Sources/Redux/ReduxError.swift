
public enum ReduxError: Error {
    case unknown(_ message: String)
    case decodeFailed
}
