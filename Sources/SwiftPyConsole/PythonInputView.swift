//
//  PythonInputView.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-01-30.
//


//
//  PythonInputView.swift
//  
//
//  Created by Tibor Felföldy on 2024-07-03.
//

import SwiftUI
import DebugTools
import Highlightr

@MainActor
extension Highlightr {
    static let standard: Highlightr? = {
        let highlightr = Highlightr()
        highlightr?.setTheme(to: "ocean")
        return highlightr
    }()
}

@Observable
@MainActor
class PythonInputLog: SortableLog {
    struct LineComponent: Identifiable {
        let id: Int
        let indentation: Int
        let highlighted: AttributedString
    }
    
    nonisolated static func == (lhs: PythonInputLog, rhs: PythonInputLog) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let date: Date
    let executionTime: UInt64?

    let highlighted: AttributedString

    init(id: UUID, input: String, date: Date, executionTime: UInt64) {
        self.id = id.uuidString
        self.date = date
        
        if let code = Highlightr.standard?.highlight(input) {
            highlighted = AttributedString(code)
        } else {
            highlighted = AttributedString(input)
        }

        self.executionTime = executionTime
    }
    
    var duration: String? {
        guard let executionTime else { return nil }
        return Duration.nanoseconds(executionTime)
            .formatted(.units(allowed: [.milliseconds, .seconds],
                              fractionalPart: .show(length: 2, rounded: .up)))
    }
}

struct PythonInputView: View {
    @State var log: PythonInputLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                Text(log.highlighted)
                
                // Execution time.
                if let duration = log.duration {
                    Label(duration, systemImage: "timer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(4)
            
            Divider()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ScrollView {
        PythonInputView(log: PythonInputLog(id: UUID(), input: """
    class SomeClass:
        def some_very_long_function_name_what_must_be_broken(count: int) -> str:
            for i in range(count):
                print(f"row {i+1}")
            
            return "yeah"
    """, date: .now, executionTime: 32))
    }
}
