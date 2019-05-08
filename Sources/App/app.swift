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
    
    // The job interval describes the frequency the cleanup cycle occurs.
    // Defaults to once every minute.
    #if DEBUG
    var jobInterval: TimeInterval = 10
    #else
    var jobInterval: TimeInterval = 60
    #endif
    if let interval = Environment.get("CLEANUP_JOB_INTERVAL"), let value = Double(interval) {
        jobInterval = value
    }
    
    if let logger = try? app.make(Logger.self) {
        logger.info("Instance lifetime: \(Instance.lifetime) seconds")
        logger.info("Token lifetime: \(Token.lifetime) seconds")
        logger.info("Cleanup job interval: \(jobInterval) seconds")
    }
    
    // Schedule a cleanup job.
    Jobs.add(interval: .seconds(jobInterval)) {
        guard let connection = jobConnection, let logger = try? app.make(Logger.self) else { return }
        
        #if DEBUG
        logger.debug("Running cleanup job")
        #endif

        // Delete expired instances.
        let instances = try Instance.query(on: connection).filter(\Instance.expiresAt, .lessThanOrEqual, Date()).all().wait()
        for instance in instances {
            _ = instance.delete(on: connection)
            logger.info("Deleted expired instance \(instance.serviceName) (\(instance.location))")
        }
        
        // Delete expired user tokens.
        let tokens = try Token.query(on: connection).filter(\Token.expiresAt, .lessThanOrEqual, Date()).all().wait()
        for token in tokens {
            _ = token.delete(on: connection)
            logger.info("Deleted expired user token for \(token.userID)")
        }
    }
    
    return app
}
