public struct PlayerCharacter: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public var name: String
    public var hearts: Int
    public var rupees: Int
    public var attack: Int

    public init(
        id: String,
        name: String,
        hearts: Int,
        rupees: Int,
        attack: Int
    ) {
        self.id = id
        self.name = name
        self.hearts = hearts
        self.rupees = rupees
        self.attack = attack
    }

    public func attacking(_ target: PlayerCharacter) -> PlayerCharacter {
        var updatedTarget = target
        updatedTarget.hearts = max(0, updatedTarget.hearts - attack)
        return updatedTarget
    }
}

public extension PlayerCharacter {
    static let link = PlayerCharacter(
        id: "hero-of-time",
        name: "Link",
        hearts: 13,
        rupees: 250,
        attack: 35
    )

    static let zelda = PlayerCharacter(
        id: "princess-zelda",
        name: "Zelda",
        hearts: 10,
        rupees: 180,
        attack: 28
    )

    static let ganondorf = PlayerCharacter(
        id: "gerudo-king",
        name: "Ganondorf",
        hearts: 20,
        rupees: 999,
        attack: 60
    )

    static let impa = PlayerCharacter(
        id: "impa",
        name: "Impa",
        hearts: 12,
        rupees: 140,
        attack: 24
    )

    static let midna = PlayerCharacter(
        id: "midna",
        name: "Midna",
        hearts: 11,
        rupees: 210,
        attack: 31
    )

    static let sidon = PlayerCharacter(
        id: "prince-sidon",
        name: "Sidon",
        hearts: 14,
        rupees: 320,
        attack: 22
    )

    static let featured: [PlayerCharacter] = [
        .link,
        .zelda,
        .ganondorf,
        .impa,
        .midna,
        .sidon
    ]
}
