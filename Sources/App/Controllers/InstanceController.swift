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
        // public routes
        let instanceRoutes = router.grouped("api", "instances")
        instanceRoutes.post(use: createHandler)
        instanceRoutes.get(use: getAllHandler)
        instanceRoutes.put(Instance.parameter, "ping", use: pingHandler)
        instanceRoutes.delete(Instance.parameter, use: deleteHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Instance]> {
        let logger = try req.make(Logger.self)
        
        #if DEBUG
        logger.debug("GET \(req.http.urlString)")
        #endif
        
        return Instance.query(on: req).all()
    }
    
    func createHandler(_ req: Request) throws -> Future<Instance> {
        let logger = try req.make(Logger.self)
        
        #if DEBUG
        logger.debug("POST \(req.http.urlString)")
        #endif
        
        return try req.content.decode(Instance.self).flatMap(to: Instance.self) { (instance) in
            logger.info("Created \(instance.serviceName) instance (\(instance.location))")
            instance.updateDigest()
            return instance.save(on: req)
        }
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
}
