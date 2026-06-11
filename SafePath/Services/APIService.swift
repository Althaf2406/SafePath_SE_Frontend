    import Foundation
import Combine

/// Generic wrapper for SafePath API responses: { success, count, data }.
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let count: Int?
    let data: T
}

/// Async networking layer for the SafePath Express backend.
final class APIService {
    
    static let shared = APIService()
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)
        
        decoder = JSONDecoder()
        
        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let standardFormatter = ISO8601DateFormatter()
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = fractionalFormatter.date(from: dateString) {
                return date
            }
            if let date = standardFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
        }
    }
    
    // MARK: - Generic GET
    
    /// Fetch and decode a `T` from a SafePath API endpoint.
    func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = SessionManager.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        logRequest(request)
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
            logResponse(response, data: data, error: nil)
        } catch {
            logResponse(nil, data: nil, error: error, url: url.absoluteString)
            throw APIError.networkFailure(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.badResponse(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMsg = errorDict["error"] as? String {
                throw APIError.serverError(errorMsg)
            }
            throw APIError.badResponse(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Convenience: unwrap APIResponse wrapper
    
    /// Fetch, unwrap the `data` field from the standard `{ success, data }` wrapper.
    func fetchData<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let wrapper: APIResponse<T> = try await get(endpoint)
        return wrapper.data
    }
}

extension APIService {
 
    /// Send a POST/PUT/DELETE request with an optional JSON body and Bearer token.
    /// Returns the decoded response of type `T`.
    func send<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: [String: Any]? = nil
    ) async throws -> T {
        print("👉 [DEBUG-API] Build request untuk \(endpoint.path)")
        let request = try buildRequest(for: endpoint, body: body)
 
        logRequest(request)
 
        let data: Data
        let response: URLResponse
 
        do {
            print("👉 [DEBUG-API] Memulai session.data(for: request)...")
            (data, response) = try await session.data(for: request)
            print("👉 [DEBUG-API] Berhasil mendapat response dari server!")
            logResponse(response, data: data, error: nil)
        } catch {
            print("👉 [DEBUG-API] Gagal mendapat response: \(error.localizedDescription)")
            logResponse(nil, data: nil, error: error, url: request.url?.absoluteString)
            throw APIError.networkFailure(error)
        }
 
        guard let http = response as? HTTPURLResponse else {
            throw APIError.badResponse(statusCode: -1)
        }
        guard (200...299).contains(http.statusCode) else {
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMsg = errorDict["error"] as? String {
                throw APIError.serverError(errorMsg)
            }
            throw APIError.badResponse(statusCode: http.statusCode)
        }
 
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
 
    /// Send a request that returns no meaningful response body (e.g. logout, DELETE).
    func sendVoid(
        _ endpoint: APIEndpoint,
        body: [String: Any]? = nil
    ) async throws {
        let request = try buildRequest(for: endpoint, body: body)
 
        logRequest(request)
 
        let response: URLResponse
        let responseData: Data
 
        do {
            let (data, res) = try await session.data(for: request)
            responseData = data
            response = res
            logResponse(response, data: responseData, error: nil)
        } catch {
            logResponse(nil, data: nil, error: error, url: request.url?.absoluteString)
            throw APIError.networkFailure(error)
        }
 
        guard let http = response as? HTTPURLResponse else {
            throw APIError.badResponse(statusCode: -1)
        }
        guard (200...299).contains(http.statusCode) else {
            if let errorDict = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let errorMsg = errorDict["error"] as? String {
                throw APIError.serverError(errorMsg)
            }
            throw APIError.badResponse(statusCode: http.statusCode)
        }
    }
 
    // MARK: - Private Builder
 
    private func buildRequest(
        for endpoint: APIEndpoint,
        body: [String: Any]?
    ) throws -> URLRequest {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }
 
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
 
        if let token = SessionManager.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
 
        return request
    }
    
    // MARK: - Logging Helpers
    
    private func logRequest(_ request: URLRequest) {
        #if DEBUG
        print("\n⬆️ =================== API REQUEST ===================")
        print("🌐 [\(request.httpMethod ?? "GET")] \(request.url?.absoluteString ?? "")")
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📝 Headers: \(headers)")
        }
        if let body = request.httpBody, let jsonString = String(data: body, encoding: .utf8) {
            print("📦 Body: \(jsonString)")
        }
        print("======================================================\n")
        #endif
    }
    
    private func logResponse(_ response: URLResponse?, data: Data?, error: Error?, url: String? = nil) {
        #if DEBUG
        print("\n⬇️ =================== API RESPONSE ===================")
        if let error = error {
            print("❌ [ERROR] \(url ?? "")")
            print("Description: \(error.localizedDescription)")
        } else if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            let icon = (200...299).contains(statusCode) ? "✅" : "⚠️"
            print("\(icon) [\(statusCode)] \(httpResponse.url?.absoluteString ?? "")")
            
            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                // Truncate extremely long responses so the console doesn't hang
                if jsonString.count > 2000 {
                    print("📦 Data: \(jsonString.prefix(2000))... (Truncated)")
                } else {
                    print("📦 Data: \(jsonString)")
                }
            }
        }
        print("=======================================================\n")
        #endif
    }
}
