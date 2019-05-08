//
//  DefaultUser.swift
//  App
//
//  Created by Jeroen Wesbeek on 08/05/2019.
//

import Foundation
import Vapor
import FluentSQLite
import Authentication

/// Default User
struct DefaultUser: Migration {
    typealias Database = SQLiteDatabase
    
    static func prepare(on connection: SQLiteConnection) -> EventLoopFuture<Void> {
        // Get the admin credentials from the environment, if possible.
        let name = Environment.get("DEFAULT_USER") ?? "Default user"
        let username = Environment.get("DEFAULT_USER_USERNAME") ?? "user"
        let password = Environment.get("DEFAULT_USER_PASSWORD") ?? "user"
        
        guard let hashedPassword = try? BCrypt.hash(password) else {
            fatalError("Failed to create default user")
        }
        
        let user = User(name: name, username: username, password: hashedPassword)
        return user.save(on: connection).transform(to: ())
    }
    
    static func revert(on connection: SQLiteConnection) -> EventLoopFuture<Void> {
        return .done(on: connection)
    }
}
