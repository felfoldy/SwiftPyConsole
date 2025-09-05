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
                                    if completion == input.selectedCompletion {
                                        Button(text) {
                                            input.setCompletion(completion)
                                        }
                                        .buttonStyle(.glassProminent)
                                    } else {
                                        Button(text) {
                                            input.setCompletion(completion)
                                        }
                                        .buttonStyle(.glass)
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
                .buttonStyle(.glassProminent)
                .padding(8)
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
