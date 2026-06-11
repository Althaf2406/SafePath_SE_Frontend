import Foundation
import Combine

/// Errors raised by the SafePath API layer.
enum APIError: LocalizedError {
    case invalidURL
    case badResponse(statusCode: Int)
    case decodingError(Error)
    case networkFailure(Error)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .badResponse(let code):
            return "Server responded with status \(code)."
        case .decodingError(let err):
            return "Failed to decode response: \(err.localizedDescription)"
        case .networkFailure(let err):
            return "Network error: \(err.localizedDescription)"
        case .serverError(let msg):
            return "Server error: \(msg)"
        }
    }
}
