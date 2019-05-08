import Vapor
import Leaf

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Site
    router.get { req -> Future<View> in
        let leaf = try req.make(LeafRenderer.self)
        let context = [String: String]()
        return leaf.render("index", context)
    }
    
    // Ping
    router.get("/api/ping") { req in
        return "pong" as StaticString
    }
    
    let instanceController = InstanceController()
    try router.register(collection: instanceController)
    
    let usersController = UsersController()
    try router.register(collection: usersController)
}
