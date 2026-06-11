import Foundation

protocol APIServiceProtocol {
    func send<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: [String: Any]?
    ) async throws -> T
    
    func sendVoid(
        _ endpoint: APIEndpoint,
        body: [String: Any]?
    ) async throws
}

extension APIServiceProtocol {
    func send<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: [String: Any]? = nil
    ) async throws -> T {
        return try await send(endpoint, body: body)
    }
    
    func sendVoid(
        _ endpoint: APIEndpoint,
        body: [String: Any]? = nil
    ) async throws {
        try await sendVoid(endpoint, body: body)
    }
}

extension APIService: APIServiceProtocol {}
