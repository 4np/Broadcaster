import App
import Vapor
import Backtrace

// Show crash tracelogs on Linux.
// See: https://github.com/swift-server/guides#building-for-production
// See: https://github.com/swift-server/swift-backtrace#usage
Backtrace.install()

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()
