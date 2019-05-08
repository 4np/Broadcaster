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

/// An ephermal authentication token that identifier a registered user.
final class Token: Codable {
    /// The lifetime of a token in seconds, after which the token will expire.
    #if DEBUG
    public static let lifetime: TimeInterval = 60 * 5
    #else
    public static let lifetime: TimeInterval = (Environment.get("TOKEN_LIFETIME") != nil) ? Double(Environment.get("TOKEN_LIFETIME")!)! : 60 * 60
    #endif
    /// Unique Identifier.
    var id: UUID?
    /// The unique token.
    var token: String
    /// Reference to the user that owns this token.
    var userID: User.ID
    /// When the `Instance` was created.
    var createdAt: Date?
    /// When the `Instance` was last updated.
    var updatedAt: Date?
    /// When the token will expire.
    var expiresAt: Date?
    
    /// Instantiate a new `Token`.
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
        expiresAt = Date.init(timeInterval: Token.lifetime, since: .init())
    }
}

/// Conform to the SQLLite UUID based model.
extension Token: SQLiteUUIDModel {
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}

/// Allows `Token` to be used as a Fluent migration.
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

/// Allow `Token` to be encoded to and decoded from HTTP messages.
extension Token: Content { }

/// Generate a new user token.
extension Token {
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}

/// Allow `Token` to be used as a TokenAuthenticatable's token.
extension Token: Authentication.Token {
    static let userIDKey: UserIDKey = \.userID
    typealias UserType = User
}

/// Allow `Token` to be used for `Bearer` based authentication.
extension Token: BearerAuthenticatable {
    static var tokenKey: TokenKey = \.token
}
