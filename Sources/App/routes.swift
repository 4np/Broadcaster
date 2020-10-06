import Vapor
import Fluent

func routes(_ app: Application) throws {
    // Site
    app.get { req in
        req.view.render("index")
    }
    
    // Ping
    app.get("api", "ping") { req -> String in
        return "pong"
    }
    
    // Instances
    #if DEBUG
    app.get("api", "instances") { req in
        Instance.query(on: req.db).all()
    }
    #else
    app.get("api", "instances") { req in
        return "[]"
    }
    #endif
}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // public routes
        let userRoutes = routes.grouped("api", "users")
        userRoutes.get(use: getAllHandler)
    }
    
//    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
//        #if DEBUG
//        let logger = try req.make(Logger.self)
//        logger.debug("GET \(req.http.urlString)")
//        #endif
//
//        //return User.query(on: req).all()
//        return User.query(on: req).decode(data: User.Public.self).all()
//    }
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
}
