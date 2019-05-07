//
//  Token.swift
//  App
//
//  Created by Jeroen Wesbeek on 07/05/2019.
//

import Foundation
import Vapor
import FluentSQLite
import Authentication

final class Token: Codable {
    var id: UUID?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}

extension Token: SQLiteUUIDModel { }

extension Token: Migration {
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (builder) in
            // add all fields to the database
            try addProperties(to: builder)
            // set up foreign key constraint
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension Token: Content { }

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}

extension Token: Authentication.Token {
    static let userIDKey: UserIDKey = \.userID
    //typealias UserIDType = <#type#>
    typealias UserType = User
}

extension Token: BearerAuthenticatable {
    static var tokenKey: TokenKey = \.token
}
