import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import SharedModels

public enum SharedNetworkError: Error, LocalizedError, Sendable {
    case invalidBaseURL(String)
    case invalidResponse
    case unexpectedStatusCode(Int)
    case apiError(String)

    public var errorDescription: String? {
        switch self {
        case let .invalidBaseURL(baseURL):
            return "Invalid base URL: \(baseURL)"
        case .invalidResponse:
            return "The server response was invalid."
        case let .unexpectedStatusCode(statusCode):
            return "The server returned an unexpected status code: \(statusCode)."
        case let .apiError(message):
            return message
        }
    }
}

public enum SharedNetworkEnvironment: String, CaseIterable, Sendable {
    case development

    public var stubbedBaseURLString: String {
        switch self {
        case .development:
            #if os(Android)
            return "http://10.0.2.2:8080"
            #else
            return "http://127.0.0.1:8080"
            #endif
        }
    }

    public var stubbedBaseURL: URL {
        guard let url = URL(string: stubbedBaseURLString) else {
            preconditionFailure("Stubbed base URL must always be valid.")
        }

        return url
    }
}

public final class SharedNetworkClient: Sendable {
    public static let supportedEnvironments = SharedNetworkEnvironment.allCases

    public let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public convenience init(baseURL: String) throws {
        guard let url = URL(string: baseURL) else {
            throw SharedNetworkError.invalidBaseURL(baseURL)
        }

        self.init(baseURL: url)
    }

    public convenience init(env: SharedNetworkEnvironment) {
        self.init(baseURL: env.stubbedBaseURL)
    }

    public static func make(env: SharedNetworkEnvironment) -> SharedNetworkClient {
        SharedNetworkClient(env: env)
    }

    public func fetch<T: Codable>(from endpoint: String) async throws -> T {
        let url = baseURL.appending(path: endpoint)
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SharedNetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw SharedNetworkError.unexpectedStatusCode(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw SharedNetworkError.apiError("Failed to decode response: \(error.localizedDescription)")
        }
    }

//    public func fetchCharacters() async throws -> [PlayerCharacter] {
//        let endpoint = baseURL.appending(path: "characters")
//        let (data, response) = try await session.data(from: endpoint)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw SharedNetworkError.invalidResponse
//        }
//
//        guard httpResponse.statusCode == 200 else {
//            throw SharedNetworkError.unexpectedStatusCode(httpResponse.statusCode)
//        }
//
//        do {
//            return try JSONDecoder().decode([PlayerCharacter].self, from: data)
//        } catch {
//            throw SharedNetworkError.apiError("Failed to decode characters response: \(error.localizedDescription)")
//        }
//    }
}
