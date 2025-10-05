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
    var message: String
    let tint: Color
    
    init(message: String, tint: Color) {
        self.message = message
        self.tint = tint
    }
}

struct ViewLog: SortableLog {
    let id = UUID().uuidString
    let date = Date()
    let representation: ViewRepresentation
    
    static func == (lhs: ViewLog, rhs: ViewLog) -> Bool {
        lhs.id == rhs.id
    }
}

public final class PythonLogStore: LogStore, IOStream {
    public func input(_ str: String) {
        logs.append(PythonInputLog(input: str))
    }
    
    public func executionTime(_ time: UInt64) {
        if let last = logs.last(where: { $0 is PythonInputLog }),
           let lastInput = last as? PythonInputLog,
           lastInput.executionTime == nil {
            lastInput.executionTime = time
        }
    }
    
    public func stdout(_ str: String) {
        if var last = logs.last as? PythonOutputLog, last.tint == .cyan {
            last.message += "\n" + str
            logs.removeLast()
            logs.append(last)
        } else {
            logs.append(
                PythonOutputLog(message: str, tint: .cyan)
            )
        }
    }
    
    public func stderr(_ str: String) {
        logs.append(
            PythonOutputLog(message: str, tint: .red)
        )
    }
    
    public func view(_ view: ViewRepresentation) {
        logs.append(ViewLog(representation: view))
    }
}

extension PythonLogStore: StringLogDestination {
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
