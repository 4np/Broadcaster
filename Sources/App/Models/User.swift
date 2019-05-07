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

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var password: String
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
    }
    
    // public representation of the User model
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

extension User: SQLiteUUIDModel { }

extension User: Content { }

extension User: Migration {
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        }
    }
}

extension User: Parameter { }

extension User.Public: Content { }

// MARK: Child relationship
extension User {
    var acronyms: Children<User, Instance> {
        return children(\.userID)
    }
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { (user) in
            return user.convertToPublic()
        }
    }
}

extension User: BasicAuthenticatable {
    static var usernameKey: UsernameKey = \.username
    static var passwordKey: PasswordKey = \.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

// MARK: Default Admin User
struct AdminUser: Migration {
    typealias Database = SQLiteDatabase
    
    static func prepare(on connection: SQLiteConnection) -> EventLoopFuture<Void> {
        // Get the admin credentials from the environment, if possible.
        let username = Environment.get("ADMIN_USER") ?? "admin"
        let password = Environment.get("ADMIN_PASSWORD") ?? "admin"
        
        guard let hashedPassword = try? BCrypt.hash(password) else {
            fatalError("Failed to create admin user")
        }
        
        let user = User(name: "Admin", username: username, password: hashedPassword)
        return user.save(on: connection).transform(to: ())
    }
    
    static func revert(on connection: SQLiteConnection) -> EventLoopFuture<Void> {
        return .done(on: connection)
    }
}
