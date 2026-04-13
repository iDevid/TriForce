import Testing
@testable import SharedModels

@Test
func attackingAnotherCharacterRemovesAttackValueFromTheirHearts() async throws {
    let attacker = PlayerCharacter.link
    let defender = PlayerCharacter.zelda

    let updatedDefender = attacker.attacking(defender)

    #expect(updatedDefender.hearts == max(0, defender.hearts - attacker.attack))
    #expect(updatedDefender.rupees == defender.rupees)
    #expect(attacker.hearts == 13)
}

@Test
func attackDoesNotDropHeartsBelowZero() async throws {
    let attacker = PlayerCharacter(
        id: "test-attacker",
        name: "Test Attacker",
        hearts: 4,
        rupees: 10,
        attack: 999
    )
    let defender = PlayerCharacter(
        id: "test-defender",
        name: "Test Defender",
        hearts: 4,
        rupees: 40,
        attack: 5
    )

    let updatedDefender = attacker.attacking(defender)

    #expect(updatedDefender.hearts == 0)
}
