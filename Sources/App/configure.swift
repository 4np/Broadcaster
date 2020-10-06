import Vapor
import Leaf
import Fluent
import FluentSQLiteDriver

// see: https://www.vknabel.com/pages/Upgrading-a-server-side-Swift-project-to-Vapor-4/
// see: https://docs.vapor.codes/4.0/fluent/migration/

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Leaf
    app.views.use(.leaf)
    app.leaf.configuration.rootDirectory = templateFolder
    app.leaf.sources = .singleSource(NIOLeafFiles(fileio: app.fileio,
                                                  limits: .default,
                                                  sandboxDirectory: projectFolder,
                                                  viewDirectory: templateFolder))
    app.leaf.cache.isEnabled = false
    
    // database configuration
    app.databases.use(.sqlite(.memory), as: .sqlite)
    
    // database migrations
    app.migrations.add(UserCreation())
    app.migrations.add(InstanceCreation())
    // set auto migrations (for in-memory sqlite)
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}

fileprivate var templateFolder: String {
    return projectFolder + "Views/"
}

fileprivate var projectFolder: String {
    let folder = #file.split(separator: "/").dropLast(3).joined(separator: "/")
    return "/" + folder + "/"
}
