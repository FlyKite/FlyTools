//
//  Logger.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/4.
//

import Foundation

protocol LoggerDelegate: AnyObject {
    func logger(_ logger: Logger, didAddLog log: Log)
    func loggerDidClear(_ logger: Logger)
}

class Logger {
    
    static let shared: Logger = Logger()
    
    var level: LogLevel = .info
    
    var logs: [Log] { queue.sync { innerLogs } }
    
    weak var delegate: LoggerDelegate?
    
    private var innerLogs: [Log] = []
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.FlyTools.Logger")
    
    private let dateFormatter: DateFormatter = DateFormatter()
    
    private init() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    func addLog(level: LogLevel, message: String, file: String, line: Int, function: String) {
        guard level >= self.level else { return }
        queue.async {
            let time = Date()
            let formattedTime = self.dateFormatter.string(from: time)
            let filename = (file as NSString).pathComponents.last ?? file
            let log = Log(level: level, time: time, formattedTime: formattedTime, filePath: file, filename: filename, function: function, line: line, message: message)
            self.innerLogs.append(log)
            self.delegate?.logger(self, didAddLog: log)
            print("\(level.consoleMark) \(log.formattedHeader)\n\(log.message)")
        }
    }
    
    func clear() {
        queue.async {
            self.innerLogs = []
            self.delegate?.loggerDidClear(self)
        }
    }
}
