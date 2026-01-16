//
//  CompletionsBarView.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-08-21.
//

import SwiftUI

struct CompletionsBarModifier: ViewModifier {
    @ObservedObject var input: InputProcessor

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .bottom) {
            HStack(spacing: 8) {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(input.completions, id: \.self) { completion in
                                let text = completion == "\t" ? "tab" : completion
                                
                                Group {
                                    if input.completions.count == 1 {
                                        Button(text) {
                                            input.setCompletion(completion)
                                        }
                                        #if !os(visionOS)
                                        .buttonStyle(.glassProminent)
                                        #endif
                                    } else {
                                        Button(text) {
                                            input.setCompletion(completion)
                                        }
                                        #if !os(visionOS)
                                        .buttonStyle(.glass)
                                        #endif
                                    }
                                }
                                .id(completion)
                            }
                        }
                        .padding(8)
                    }
                }

                Button {
                    input.submit()
                } label: {
                    Image(systemName: "play")
                }
                #if !os(visionOS)
                .buttonStyle(.glassProminent)
                .padding(8)
                #endif
            }
            .frame(minHeight: 48)
        }
    }
}

extension View {
    func completionsBar(for input: InputProcessor) -> some View {
        modifier(CompletionsBarModifier(input: input))
    }
}
