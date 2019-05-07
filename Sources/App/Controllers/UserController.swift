//
//  UserController.swift
//  App
//
//  Created by Jeroen Wesbeek on 07/05/2019.
//

import Vapor
import Fluent
import Crypto

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        // public routes
        let userRoutes = router.grouped("api", "users")
        //userRoutes.post(User.self, use: createHandler)
        //userRoutes.get(use: getAllHandler)
        //userRoutes.get(User.parameter, use: getHandler)
        
        // authenticated routes
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = userRoutes.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
        
        // authenticated routes
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = userRoutes.grouped([tokenAuthMiddleware, guardAuthMiddleware])
        tokenAuthGroup.post(User.self, use: createHandler)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        #if DEBUG
        let logger = try req.make(Logger.self)
        logger.debug("POST \(req.http.urlString)")
        #endif
        
        // hash the user's password
        user.password = try BCrypt.hash(user.password)
        
        // return the public representation of a user (without the password)
        return user.save(on: req).convertToPublic()
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        #if DEBUG
        let logger = try req.make(Logger.self)
        logger.debug("GET \(req.http.urlString)")
        #endif
        
        //return User.query(on: req).all()
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        #if DEBUG
        let logger = try req.make(Logger.self)
        logger.debug("GET \(req.http.urlString)")
        #endif
        
        //return try req.parameters.next(User.self)
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
        #if DEBUG
        let logger = try req.make(Logger.self)
        logger.debug("POST \(req.http.urlString)")
        #endif
        
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
}
