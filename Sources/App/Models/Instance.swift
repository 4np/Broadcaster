//
//  Instance.swift
//  App
//
//  Created by Jeroen Wesbeek on 03/05/2019.
//

import Vapor
import FluentSQLite
import Crypto

struct InstanceCreateData: Content {
    var id: UUID?
    /// The instance name (main, oem, node b, etcetera).
    var name: String
    /// The instance version that is running.
    var version: String
    /// The track of the instance.
    var track: String
    /// The ip of the machine running the instance.
    var ip: String
    /// The port on which the instance is exposed.
    var port: Int
    /// The full name of the user running the instance.
    var fullName: String
    /// The user name of the user running the instance.
    var userName: String
    /// The location of the instance.
    var location: String
    /// A hash of all the values that make this model unique.
    var digest: String?
}

final class Instance: Codable {
    /// The lifetime of an instance since last update, before it gets deleted.
    #if DEBUG
    public static let lifetime: TimeInterval = 60
    #else
    public static let lifetime: TimeInterval = (Environment.get("INSTANCE_LIFETIME") != nil) ? Double(Environment.get("INSTANCE_LIFETIME")!)! : 60 * 10
    #endif
    /// The unique identifier for this `Instance`.
    var id: UUID?
    /// The instance name (main, oem, node b, etcetera).
    var name: String
    /// The instance version that is running.
    var version: String
    /// The track of the instance.
    var track: String
    /// The ip of the machine running the instance.
    var ip: String
    /// The port on which the instance is exposed.
    var port: Int
    /// The full name of the user running the instance.
    var fullName: String
    /// The user name of the user running the instance.
    var userName: String
    /// The location of the instance.
    var location: String
    /// A hash of all the values that make this model unique.
    var digest: String?
    /// Relationship
    var userID: User.ID
    /// When the `Instance` was created.
    var createdAt: Date?
    /// When the `Instance` was last updated.
    var updatedAt: Date?
    /// When the `Instance` will expire.
    var expiresAt: Date?
    
    /// Create a service name for logging purposes.
    var serviceName: String {
        let components = fullName.components(separatedBy: " ")
        var user = components.first ?? "unknown"
        
        if components.count >= 2, let first = components.first, let character = components[1].first {
            user = "\(first)\(character)'s"
        }
        
        let elements = [user, version, name, "(\(track))"]
        return elements.joined(separator: " ")
    }
    
    init(version: String, name: String, track: String, ip: String, port: Int, fullName: String, userName: String, location: String, userID: User.ID) {
        self.name = name
        self.version = version
        self.track = track
        self.ip = ip
        self.port = port
        self.fullName = fullName
        self.userName = userName
        self.location = location
        self.userID = userID
        updateExpiry()
    }
}

/// Conform to the SQLLite UUID based model.
extension Instance: SQLiteUUIDModel {
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}

/// Allows `Instance` to be used as a Fluent migration.
extension Instance: Migration {
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.digest)
        }
    }
}

/// Allow `Instance` to be used as a request parameter.
extension Instance: Parameter { }

/// Allow `Instance` to be encoded to and decoded from HTTP messages.
extension Instance: Content { }

/// elationships.
extension Instance {
    // Parent relationship
    var user: Parent<Instance, User> {
        return parent(\.userID)
    }
}

// Hashing.
extension Instance {
    func updateDigest() {
        guard digest == nil else { return }
        
        // Calculate a SHA1 hash for all things that make this instance unique, while
        // ignoring:    - ip (as this is prone to change)
        //              - full name (as user name is better suited)
        if let digest = try? SHA1.hash(name + version + track + String(port) + userName + location) {
            self.digest = digest.hexEncodedString()
        }
    }
}

/// Keeping the instance alive.
extension Instance {
    /// Update the instance expiry, so it not will be deleted in the clean-up cycle.
    func updateExpiry() {
        expiresAt = Date.init(timeInterval: Instance.lifetime, since: .init())
    }
}
