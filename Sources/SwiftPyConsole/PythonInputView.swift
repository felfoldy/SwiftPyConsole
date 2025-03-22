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
    static let light: Highlightr? = {
        let highlighter = Highlightr()
        highlighter?.setTheme(to: "atom-one-light")
        return highlighter
    }()
    
    static let dark: Highlightr? = {
        let highlighter = Highlightr()
        highlighter?.setTheme(to: "atom-one-dark")
        return highlighter
    }()
}

@Observable
@MainActor
class PythonInputLog: SortableLog {
    nonisolated static func == (lhs: PythonInputLog, rhs: PythonInputLog) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID().uuidString
    let date = Date.now
    var input: String
    var executionTime: UInt64?

    init(input: String) {
        self.input = input
    }
    
    var duration: String? {
        guard let executionTime else { return nil }
        return Duration.nanoseconds(executionTime)
            .formatted(.units(allowed: [.milliseconds, .seconds],
                              fractionalPart: .show(length: 2, rounded: .up)))
    }
    
    func highlight(isLight: Bool) -> AttributedString {
        let highlighter: Highlightr? = isLight ? .light : .dark

        if let code = highlighter?.highlight(input, as: "python") {
            return AttributedString(code)
        } else {
            return AttributedString(input)
        }
    }
}

struct PythonInputView: View {
    @State var log: PythonInputLog
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                Text(log.highlight(isLight: colorScheme == .light))
                
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
    }
}

#Preview {
    ScrollView {
        PythonInputView(log: PythonInputLog(input: """
    class SomeClass:
        def some_very_long_function_name_what_must_be_broken(count: int) -> str:
            for i in range(count):
                print(f"row {i+1}")
            
            return "yeah"
    """))
    }
}
