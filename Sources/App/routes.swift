import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Ping
    router.get("ping") { req in
        return "pong" as StaticString
    }
    
    let instanceController = InstanceController()
    try router.register(collection: instanceController)
}
