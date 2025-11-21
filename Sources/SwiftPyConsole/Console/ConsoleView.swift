//
//  ConsoleView.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-01-28.
//

import DebugTools
import SwiftUI
import SwiftPy
#if canImport(QuickLook)
import QuickLook
#endif

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

public struct PythonConsoleView: View {
    @StateObject private var input = InputProcessor()
    @ObservedObject private var store = SwiftPyConsole.store

    @State private var console = Console.shared

    public var body: some View {
        ConsoleView(store: store) { log in
            if let inputLog = log as? PythonInputLog {
                PythonInputView(log: inputLog)
            }

            if let outputLog = log as? PythonOutputLog {
                LogContainerView(tint: outputLog.tint) {
                    Text(outputLog.message)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if let viewableLog = log as? ViewLog {
                viewableLog.representation.view
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
        .onAppear {
            console._isPresented = true
        }
        .onDisappear {
            console._isPresented = false
        }
        #if os(visionOS)
        .font(.system(size: 24))
        .frame(width: 800, alignment: .leading)
        #else
        .quickLookPreview($console.previewURL)
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
