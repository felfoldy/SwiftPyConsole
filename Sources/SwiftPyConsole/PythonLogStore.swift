//
//  PythonLogStore.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-01-28.
//

import DebugTools
import SwiftPy
import SwiftUI
import LogTools
import OSLog

struct PythonOutputLog: SortableLog, Hashable {
    let id = UUID().uuidString
    let date = Date()
    let message: String
    let tint: Color
    
    init(message: String, tint: Color) {
        self.message = message
        self.tint = tint
    }
}

public final class PythonLogStore: LogStore, SwiftPy.OutputStream {
    init() {
        super.init(logFilter: .none)
        // Set log destination.
        Logger.destinations.append(self)
        
        // Set output stream.
        Interpreter.output = self
        
        // Clear console.
        Interpreter.main.bind(#def("clear") {
            self.logs.removeAll()
        })
    }
    
    public func stdout(_ str: String) {
        logs.append(
            PythonOutputLog(message: str, tint: .cyan)
        )
    }
    
    public func stderr(_ str: String) {
        logs.append(
            PythonOutputLog(message: str, tint: .red)
        )
    }
}

extension PythonLogStore: LogDestination {
    nonisolated public func log(subsystem: String?, category: String?, level: LogTools.LogLevel, _ message: String, file: String, function: String, line: Int) {
        guard let url = URL(string: file) else { return }
        
        let level: OSLogEntryLog.Level = {
            switch level {
            case .debug: .debug
            case .default: .notice
            case .info: .info
            case .error: .error
            case .fault: .fault
            default: .undefined
            }
        }()
        
        let path = url.deletingPathExtension().lastPathComponent
        let location = "\(path).\(function):\(line)"
        
        let entry = LogEntry(subsystem: subsystem,
                             category: category,
                             message: message,
                             level: level,
                             location: location)

        Task { @MainActor in
            logs.append(entry)
        }
    }
}
