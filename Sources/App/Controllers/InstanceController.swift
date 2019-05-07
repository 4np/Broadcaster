//
//  InstanceController.swift
//  App
//
//  Created by Jeroen Wesbeek on 03/05/2019.
//

import Vapor
import Fluent

struct InstanceController: RouteCollection {
    func boot(router: Router) throws {
        // Public routes
        let instanceRoutes = router.grouped("api", "instances")
        
        // Authenticated routes
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = instanceRoutes.grouped([tokenAuthMiddleware, guardAuthMiddleware])
        tokenAuthGroup.post(InstanceCreateData.self, use: createHandler)
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.put(Instance.parameter, "ping", use: pingHandler)
        tokenAuthGroup.delete(Instance.parameter, use: deleteHandler)
        tokenAuthGroup.get("search", use: searchHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Instance]> {
        #if DEBUG
        let logger = try req.make(Logger.self)
        logger.debug("GET \(req.http.urlString)")
        #endif
        
        return Instance.query(on: req).all()
    }
    
    func createHandler(_ req: Request, data: InstanceCreateData) throws -> Future<Instance> {
        let logger = try req.make(Logger.self)
        
        #if DEBUG
        logger.debug("POST \(req.http.urlString)")
        #endif

        let user = try req.requireAuthenticated(User.self)
        let instance = try Instance(version: data.version,
                                    name: data.name,
                                    track: data.track,
                                    ip: data.ip,
                                    port: data.port,
                                    fullName: data.fullName,
                                    userName: data.userName,
                                    location: data.location,
                                    userID: user.requireID())
        instance.updateDigest()
        
        logger.info("Created \(instance.serviceName) instance (\(instance.location))")
        return instance.save(on: req)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let logger = try req.make(Logger.self)
        
        #if DEBUG
        logger.debug("DELETE \(req.http.urlString)")
        #endif
        
        return try req.parameters.next(Instance.self)
            .delete(on: req)
            .map(to: Instance.self) { (instance) in
                logger.info("Deleted \(instance.serviceName) instance (\(instance.location))")
                return instance
            }
            .transform(to: HTTPStatus.noContent)
    }
    
    /// The ping request will update the instance's `updatedAt` date to keep it alive.
    func pingHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let logger = try req.make(Logger.self)
        
        #if DEBUG
        logger.debug("GET \(req.http.urlString)")
        #endif
        
        return try req
            .parameters.next(Instance.self)
            .map(to: Instance.self) { (instance) in
                logger.info("Keeping \(instance.serviceName) instance alive (\(instance.location))")
                return instance
            }
            .update(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func searchHandler(_ req: Request) throws -> Future<Instance> {
        let logger = try req.make(Logger.self)
        
        #if DEBUG
        logger.debug("GET \(req.http.urlString)")
        #endif
        
        guard let digest = req.query[String.self, at: "digest"] else {
            throw Abort(.badRequest)
        }
        
        return Instance.query(on: req).filter(\.digest == digest).first().map(to: Instance.self) { (instance) in
            guard let instance = instance else {
                throw Abort(.notFound)
            }
            
            logger.info("Searched \(instance.serviceName) instance by digest (\(instance.location))")

            return instance
        }
    }
}
