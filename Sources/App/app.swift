import Vapor
import Jobs
import os.log

/// Creates an instance of `Application`. This is called from `main.swift` in the run target.
public func app(_ env: Environment) throws -> Application {
    var config = Config.default()
    var env = env
    var services = Services.default()
    try configure(&config, &env, &services)
    let app = try Application(config: config, environment: env, services: services)
    try boot(app)
    
    // Get a job connection from the pool
    let jobConnection = try? app.requestPooledConnection(to: .sqlite).wait()
    
    // Schedule a cleanup job that runs every minute
    Jobs.add(interval: .seconds(60)) {
        guard let connection = jobConnection else { return }

        // Find instances that have not been kept alive for more than
        // ten minutes.
        let expiry = Date().addingTimeInterval(60 * 10)
        let instances = try Instance.query(on: connection).filter(\Instance.fluentUpdatedAt, .lessThanOrEqual, .init(expiry)).all().wait()
        
        guard !instances.isEmpty else { return }

        if #available(OSX 10.12, *) {
            os_log("Delete %d expired instance(s).", log: .default, type: .debug, instances.count)
        }
        
        // Delete expired instances
        for instance in instances {
            _ = instance.delete(on: connection)
        }
    }
    
    return app
}
