import Vapor
import SharedModels

func routes(_ app: Application) throws {
    app.get { _ async in
        "TriForce Vapor backend is running."
    }

    app.get("health") { _ async in
        ["status": "ok"]
    }

    app.get("characters") { _ async in
        PlayerCharacter.featured
    }
}
