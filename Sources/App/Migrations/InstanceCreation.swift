//
//  InstanceCreation.swift
//  
//
//  Created by Jeroen Wesbeek on 03/10/2020.
//

import Fluent

struct InstanceCreation: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("instances")
            .id()
            .field("name", .string, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "name")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("instances").delete()
    }
}
