//
//  Instance.swift
//  
//
//  Created by Jeroen Wesbeek on 03/10/2020.
//

import Vapor
import Fluent
//import Crypto

final class Instance: Model {
    // Name of the table or collection.
    static let schema = "instances"

    // Unique identifier for this `Instance`.
    @ID(key: .id)
    var id: UUID?

    // The `Instance`'s name.
    @Field(key: "name")
    var name: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    // Creates a new, empty Instance.
    init() { }

    // Creates a new Instance with all properties set.
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

/// Allow `Instance` to be encoded to and decoded from HTTP messages.
extension Instance: Content { }
