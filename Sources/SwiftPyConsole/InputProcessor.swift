//
//  InputProcessor.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-01-28.
//

import Foundation
import SwiftPy

@MainActor
final class InputProcessor: ObservableObject {
    @Published var text: String = ""
    @Published var selectedCompletion: String?
    @Published private(set) var completions: [String] = []
    
    init() {
        $text
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { text -> [String] in
                if text.hasSuffix("(") {
                    return [text + ")"]
                }
                let lastComponent = text
                    .lastComponent
                    .debugDescription
                    .trimmingCharacters(
                        in: CharacterSet(["\""])
                    )
                return Interpreter.complete(lastComponent)
            }
            .assign(to: &$completions)
        
        $completions
            .map {
                $0.count == 1 ? $0.first : nil
            }
            .assign(to: &$selectedCompletion)
    }
    
    func setCompletion(_ completion: String) {
        if completion.hasSuffix("()") {
            Interpreter.input(completion)
            text = ""
            completions = []
            return
        }
        let lastComponent = text.lastComponent
        text = text.dropLast(lastComponent.count) + completion
    }
    
    func submit() {
        let code = text
        text = ""
        completions = []

        Task { await Interpreter.asyncRun(code)}
    }
}

extension String {
    var lastComponent: String {
        let set = CharacterSet.whitespacesAndNewlines
            .union(CharacterSet(["(", "["]))
        return components(separatedBy: set).last ?? ""
    }
}
