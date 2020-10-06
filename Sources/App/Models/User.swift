//
//  User.swift
//  
//
//  Created by Jeroen Wesbeek on 03/10/2020.
//

import Vapor
import Fluent
//import Crypto

final class User: Model {
    // Name of the table or collection.
    static let schema = "users"

    /// Unique identifier for this `User`.
    @ID(key: .id)
    var id: UUID?

    /// The `User`'s name.
    @Field(key: "name")
    var name: String
    
    /// The `User`'s username.
    @Field(key: "username")
    var username: String
    
    /// A `BCrypt` hash of the `Users`'s password.
    @Field(key: "password")
    var password: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    /// Creates a new, empty `User`.
    init() { }

    /// Instantiate a new `User` with all properties set.
    init(id: UUID? = nil, name: String, username: String, password: String) {
        self.id = id
        self.name = name
        self.username = username
        self.password = password
    }
}

/// Allow `User` to be encoded to and decoded from HTTP messages.
extension User: Content { }
