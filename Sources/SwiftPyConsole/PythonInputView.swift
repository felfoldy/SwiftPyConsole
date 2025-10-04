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

@MainActor
public protocol LogViewProvider {
    var view: AnyView { get }
}

@Observable
@MainActor
class PythonInputLog: SortableLog, LogViewProvider {
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
    
    var view: AnyView {
        AnyView(PythonInputView(log: self))
    }
}

import HighlightSwift

struct PythonInputView: View {
    @State var log: PythonInputLog
    @Environment(\.colorScheme) private var colorScheme
    @State private var highlight = Highlight()
    
    @State var attributed: AttributedString?
    @State var background: Color?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                ScrollView(.horizontal) {
                    CodeText(log.input)
                        .codeTextColors(.theme(.xcode))
                        .highlightLanguage(.python)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .topLeading)
                }
                .safeAreaInset(edge: .bottom, alignment: .leading) {
                    // Execution time.
                    if let duration = log.duration {
                        Label(duration, systemImage: "timer")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding([.horizontal, .bottom], 4)
                    }
                }
                .safeAreaInset(edge: .trailing, alignment: .top) {
                    Button {
                        #if canImport(UIKit)
                        UIPasteboard.general.string = log.input
                        #else
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(log.input, forType: .string)
                        #endif
                    } label: {
                        Image(systemName: "rectangle.on.rectangle")
                            .padding(4)
                    }
                    .buttonStyle(.glass)
                    .padding(8)
                }
            }
            .background(background)
            
            Divider()
        }
    }
}

#Preview {
    ScrollView {
        PythonInputView(log: PythonInputLog(input: """
    class SomeClass:
        def some_very_long_function_name(count: int) -> str:
            for i in range(count):
                print(f"row {i+1}")
            
            return "yeah"
    """))
    }
}
