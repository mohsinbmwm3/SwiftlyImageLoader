//
//  LogLevel.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

/// Defines the logging verbosity level.
    /// - `none`: No logs.
    /// - `basic`: Only key lifecycle logs (start, success, error).
    /// - `verbose`: Includes cancellation, internal state changes, etc.
public enum LogLevel: String {
    case none, basic, verbose
}
