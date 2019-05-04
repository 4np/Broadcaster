import Vapor
import Jobs

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
    
    // The instance lifetime defines the interval since the last updated date when
    // the instance will be deleted. Keeping the instance alive will update the last
    // updated date. Defaults to 10 minutes.
    var instanceLifetime: TimeInterval = 60 * 10
    if let lifetime = Environment.get("INSTANCE_LIFETIME"), let value = Double(lifetime) {
        instanceLifetime = value
    }
    
    // The job interval describes the frequency the cleanup cycle occurs.
    // Defaults to once every minute.
    var jobInterval: TimeInterval = 60
    if let interval = Environment.get("CLEANUP_JOB_INTERVAL"), let value = Double(interval) {
        jobInterval = value
    }
    
    if let logger = try? app.make(Logger.self) {
        logger.info("Instance lifetime: \(instanceLifetime) seconds")
        logger.info("Cleanup job interval: \(jobInterval) seconds")
    }
    
    // Schedule a cleanup job that runs every minute
    Jobs.add(interval: .seconds(jobInterval)) {
        guard let connection = jobConnection, let logger = try? app.make(Logger.self) else { return }
        
        logger.debug("Running cleanup job")

        // Delete expired instances that have not been kept alive.
        let expiry = Date().addingTimeInterval(-instanceLifetime)
        let instances = try Instance.query(on: connection).filter(\Instance.fluentUpdatedAt, .lessThanOrEqual, .init(expiry)).all().wait()
        
        for instance in instances {
            _ = instance.delete(on: connection)
            logger.info("Deleted \(instance.serviceName) expired instance")
        }
    }
    
    return app
}
