//
//  ConsoleView.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-01-28.
//

import DebugTools
import SwiftUI
import SwiftPy

extension View {
    func bottom<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        #if os(visionOS)
        ornament(attachmentAnchor: .scene(.bottom)) {
            content()
                .glassBackgroundEffect(in: .rect(cornerRadius: 20))
        }
        #else
        safeAreaInset(edge: .bottom) {
            content()
                .padding(8)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16.0))
                .padding(.horizontal, 8)
        }
        #endif
    }
}

@available(macOS 14.0, *)
public struct PythonConsoleView: View {
    @StateObject private var input = InputProcessor()
    @ObservedObject private var store = SwiftPyConsole.store

    public var body: some View {
        ConsoleView(store: store) { log in
            if let outLog = log as? PythonOutputLog {
                LogContainerView(tint: outLog.tint) {
                    Text(outLog.message)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            if let inputLog = log as? PythonInputLog {
                PythonInputView(log: inputLog)
            }
        }
        .textSelection(.enabled)
        .bottom {
            TextEditor(text: $input.text)
                .textEditorStyle(.plain)
                .frame(maxHeight: 48)
                .autocorrectionDisabled()
                #if !os(macOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.asciiCapable)
                #endif
                .monospaced()
        }
        .completionsBar(for: input)
        .onKeyPress(.tab) {
            if input.completions.count == 1 {
                Task { @MainActor in
                    input.setCompletion(input.completions[0])
                }
            }
            return .handled
        }
        .onKeyPress(KeyEquivalent.return) {
            if input.returnPressed() {
                input.submit()
                return .handled
            }

            return .ignored
        }
        #if os(visionOS)
        .font(.system(size: 24))
        .frame(width: 800, alignment: .leading)
        #endif
        .fontDesign(.monospaced)
        #if os(visionOS)
        .padding(.top)
        #endif
    }
}

#Preview {
    PythonConsoleView()
}
