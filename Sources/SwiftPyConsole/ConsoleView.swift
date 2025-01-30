//
//  ConsoleView.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-01-28.
//

import DebugTools
import SwiftUI
import SwiftPy

@available(macOS 15.0, *)
public struct PythonConsoleView: View {
    @StateObject private var input = InputProcessor()
    @ObservedObject private var store = SwiftPyConsole.store

    public init() {
        SwiftPyConsole.initialize()
    }

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
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                if !input.completions.isEmpty {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(input.completions, id: \.self) { completion in
                                    let text = completion == "\t" ? "tab" : completion

                                    Group {
                                        if completion == input.selectedCompletion {
                                            Button(text) {
                                                input.setCompletion(completion)
                                            }
                                            .buttonStyle(.borderedProminent)
                                        } else {
                                            Button(text) {
                                                input.setCompletion(completion)
                                            }
                                            .buttonStyle(.bordered)
                                        }
                                    }
                                    .id(completion)
                                }
                            }
                            .padding(8)
                        }
                        .onChange(of: input.selectedCompletion) { _, newValue in
                            if let newValue {
                                withAnimation {
                                    proxy.scrollTo(newValue)
                                }
                            }
                        }
                    }
                }

                if !input.replBuffer.isEmpty {
                    VStack(alignment: .leading) {
                        ForEach(input.replBuffer, id: \.self) { line in
                            Text(line)
                        }
                    }
                    .padding(.horizontal, 8)
                }
         
                TextField(">>>", text: $input.text)
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                    #endif
                    .monospaced()
                    .onSubmit {
                        let date = Date.now
                        if let (result, time) = input.submit() {
                            store.input(result, date: date, time: time)
                        }
                    }
                    .padding([.horizontal, .bottom], 8)
                    .onKeyPress(.return) {
                        if let completion = input.selectedCompletion,
                           input.completions.count > 1 {
                            Task {
                                input.setCompletion(completion)
                            }
                            return .handled
                        }
                        return .ignored
                    }
                    .onKeyPress(.tab) {
                        if let completion = input.selectedCompletion {
                            if input.completions.count == 1 {
                                Task { @MainActor in
                                    input.setCompletion(completion)
                                }
                                return .handled
                            }
                            if let i = input.completions.firstIndex(of: completion) {
                                let next = input.completions[(i + 1) % input.completions.count]
                                Task { @MainActor in
                                    input.selectedCompletion = next
                                }
                            }
                            return .handled
                        }

                        Task {
                            input.selectedCompletion = input.completions.first
                        }
                        return .handled
                    }
            }
            .background(.thinMaterial)
        }
        .fontDesign(.monospaced)
    }
}

#Preview {
    if #available(macOS 15.0, *) {
        PythonConsoleView()
    }
}
