import Foundation
import SharedModels

public final class PlayerNetworkService: Sendable {
    private let client: SharedNetworkClient

    public init(env: SharedNetworkEnvironment) {
        self.client = SharedNetworkClient(env: env)
    }

    public func fetchCharacters() async throws -> [PlayerCharacter] {
        try await client.fetch(from: "characters")
    }
}
