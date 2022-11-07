//
//  Log.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/4.
//

import UIKit

public enum LogLevel: Int, Comparable {
    case verbose
    case debug
    case info
    case warning
    case error
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

struct Log {
    let level: LogLevel
    let time: Date
    let formattedTime: String
    let filePath: String
    let filename: String
    let function: String
    let line: Int
    let message: String
    
    var formattedHeader: String {
        "\(formattedTime) \(filename) - line \(line):"
    }
}

extension LogLevel {
    var consoleMark: String {
        switch self {
        case .verbose: return "✉️"
        case .debug: return "🌐"
        case .info: return "📟"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
    
    var logColor: UIColor {
        switch self {
        case .verbose: return .white
        case .debug: return UIColor(red: 0, green: 0.627, blue: 0.745, alpha: 1)
        case .info: return UIColor(red: 0.514, green: 0.753, blue: 0.341, alpha: 1)
        case .warning: return .yellow
        case .error: return .red
        }
    }
}
