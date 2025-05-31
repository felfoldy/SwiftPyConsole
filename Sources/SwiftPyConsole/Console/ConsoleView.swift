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
    func bottom<Content: View>(content: () -> Content) -> some View {
        #if os(visionOS)
        ornament(attachmentAnchor: .scene(.bottom)) {
            content()
                .glassBackgroundEffect(in: .rect(cornerRadius: 20))
        }
        #else
        safeAreaInset(edge: .bottom) {
            content()
                .background(.thinMaterial)
        }
        #endif
    }
}

@available(macOS 14.0, *)
public struct PythonConsoleView: View {
    @StateObject private var input = InputProcessor()
    @ObservedObject private var store = SwiftPyConsole.store

    public init() {}

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
            VStack(alignment: .leading, spacing: 0) {
                if !input.completions.isEmpty {
                    CompletionsView(input: input)
                }
         
                TextField(">>>", text: $input.text)
                    .autocorrectionDisabled()
                    #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                    #endif
                    .monospaced()
                    .onSubmit {
                        input.submit()
                    }
                    .padding(8)
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
            #if os(visionOS)
            .font(.system(size: 24))
            .frame(width: 800, alignment: .leading)
            #endif
        }
        .fontDesign(.monospaced)
        #if os(visionOS)
        .padding(.top)
        #endif
    }
}

struct CompletionsView: View {
    @ObservedObject var input: InputProcessor
    
    var body: some View {
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
                .padding([.horizontal, .top], 8)
            }
            .scrollIndicators(.hidden)
            .onChange(of: input.selectedCompletion) { _, newValue in
                if let newValue {
                    withAnimation {
                        proxy.scrollTo(newValue)
                    }
                }
            }
        }
    }
}

#Preview {
    if #available(macOS 15.0, *) {
        PythonConsoleView()
    }
}
