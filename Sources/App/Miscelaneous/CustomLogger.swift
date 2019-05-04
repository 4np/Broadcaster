//
//  CustomLogger.swift
//  App
//
//  Created by Jeroen Wesbeek on 04/05/2019.
//

import Vapor

/**
 Create a custom logger that takes into account that we want to use
 different log levels for different platforms. We don't need the debug
 log level in production.
 */
public class CustomLogger: Logger {
    /// Create a new `PrintLogger`.
    public init() { }
    
    /**
     Unfortunately Vapor's LogLevel does not conform to `CaseIterable`,
     it does not conform to to `Equatable` so the only way to evaluate
     it is to make use of `ExpressibleByStringLiteral` and compare it
     as a String :/
     */
    
    #if DEBUG
    private let levels: [LogLevel] = [.verbose, .debug, .info, .warning, .error, .fatal]
    #else
    private let levels: [LogLevel] = [.info, .warning, .error, .fatal]
    #endif
    
    /// See `Logger`.
    public func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        guard levels.map({ return "\($0)" }).index(of: "\(level)") != nil else { return }
        
        let now = Date()
        
        #if DEBUG
        Swift.print("[ \(now) - \(level) ] \(string) (\(file):\(function):\(line):\(column))")
        #else
        Swift.print("[ \(now) - \(level) ] \(string)")
        #endif
    }
}

// MARK: It needs to conform to Service (why doesn't Logger conform to Service?)
extension CustomLogger: Service { }
