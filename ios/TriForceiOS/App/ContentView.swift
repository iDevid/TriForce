import SwiftUI
import SharedModels
import SharedNetworkLayer

@MainActor
final class CharacterListViewModel: ObservableObject {
    @Published private(set) var characters: [PlayerCharacter] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private var hasLoaded = false
    private let service = PlayerNetworkService(env: .development)

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await refresh()
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            characters = try await service.fetchCharacters()
            errorMessage = nil
        } catch {
            errorMessage = "Couldn't load characters from the backend."
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = CharacterListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.characters.isEmpty {
                    ProgressView("Loading characters...")
                } else if let errorMessage = viewModel.errorMessage, viewModel.characters.isEmpty {
                    ContentUnavailableView(
                        "Backend Unavailable",
                        systemImage: "wifi.exclamationmark",
                        description: Text(errorMessage)
                    )
                } else {
                    List(viewModel.characters) { character in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(character.name)
                                .font(.headline)

                            Text("\(character.hearts) hearts • \(character.rupees) rupees")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Zelda Characters")
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}

#Preview {
    NavigationStack {
        List(PlayerCharacter.featured) { character in
            VStack(alignment: .leading, spacing: 6) {
                Text(character.name)
                    .font(.headline)

                Text("\(character.hearts) hearts • \(character.rupees) rupees")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Zelda Characters")
    }
}
