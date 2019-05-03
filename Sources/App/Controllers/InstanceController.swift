//
//  InstanceController.swift
//  App
//
//  Created by Jeroen Wesbeek on 03/05/2019.
//

import Vapor
import Fluent

#if os(macOS)
    import os.log
#endif

struct InstanceController: RouteCollection {
    func boot(router: Router) throws {
        // public routes
        let instanceRoutes = router.grouped("api", "instances")
        instanceRoutes.get(use: getAllHandler)
        instanceRoutes.get("keepalive", use: keepaliveHandler)
        instanceRoutes.post(use: createHandler)
        instanceRoutes.delete(Instance.parameter, use: deleteHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Instance]> {
        #if os(macOS)
        if #available(OSX 10.12, *) {
            os_log("GET %@", log: .default, type: .debug, req.http.urlString)
        }
        #endif
        
        return Instance.query(on: req).all()
    }
    
    func createHandler(_ req: Request) throws -> Future<Instance> {
        #if os(macOS)
        if #available(OSX 10.12, *) {
            os_log("POST %@", log: .default, type: .debug, req.description)
        }
        #endif
        
        return try req.content.decode(Instance.self).flatMap(to: Instance.self) { (instance) in
            return instance.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        #if os(macOS)
        if #available(OSX 10.12, *) {
            os_log("DELETE %@", log: .default, type: .debug, req.http.urlString)
        }
        #endif
        
        return try req.parameters.next(Instance.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func keepaliveHandler(_ req: Request) throws -> Future<HTTPStatus> {
        #if os(macOS)
        if #available(OSX 10.12, *) {
            os_log("GET %@", log: .default, type: .debug, req.http.urlString)
        }
        #endif
        
        guard let searchTerm = req.query[String.self, at: "uuid"] else {
            throw Abort(.badRequest)
        }
        
        return Instance
            .query(on: req)
            .filter(\.uuid == searchTerm).first()
            .map(to: Instance.self) { (instance) in
                guard let instance = instance else {
                    throw Abort(.notFound)
                }
                
                return instance
            }
            .update(on: req)
            .transform(to: HTTPStatus.noContent)
    }
}
