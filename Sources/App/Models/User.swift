//
//  User.swift
//  App
//
//  Created by Jeroen Wesbeek on 07/05/2019.
//

import Foundation
import Vapor
import FluentSQLite
import Authentication

/// User model.
final class User: Codable {
    /// The unique identifier for this user.
    var id: UUID?
    /// The user's name.
    var name: String
    /// The user's username.
    var username: String
    /// A BCrypt hash of the user's password.
    var password: String
    /// When the `User` was created.
    var createdAt: Date?
    /// When the `User` was last updated.
    var updatedAt: Date?
    
    /// Instantiate a new `User`.
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
    }
    
    /// Public representation of the `User` model, that will not reveal the password hash.
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        
        init(id: UUID?, name: String, username: String) {
            self.id = id
            self.name = name
            self.username = username
        }
    }
}

/// Conform to the SQLLite UUID based model.
extension User: SQLiteUUIDModel {
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}

/// Allows `User` to be used as a Fluent migration.
extension User: Migration {
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        }
    }
}

/// Child relationship.
extension User {
    /// The user's instances.
    var instances: Children<User, Instance> {
        return children(\.userID)
    }
}

/// Convert to a `User.Public` model as not to expose password hashes.
extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username)
    }
}

/// Convert to a Future `User.Public` model as not to expose password hashes.
extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { (user) in
            return user.convertToPublic()
        }
    }
}

/// Allow `User` to authenticate using HTTP Basic authentication.
extension User: BasicAuthenticatable {
    static var usernameKey: UsernameKey = \.username
    static var passwordKey: PasswordKey = \.password
}

/// Allow `User` to authenticate using a Token.
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

/// Allow `User` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allow `User.Public` to be encoded to and decoded from HTTP messages.
extension User.Public: Content { }

/// Allow `User` to be used as a request parameter.
extension User: Parameter { }
