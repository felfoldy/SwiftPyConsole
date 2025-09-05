//
//  InputProcessor.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-01-28.
//

import Foundation
import SwiftPy
import HighlightSwift

@MainActor
final class InputProcessor: ObservableObject {
    @Published var text: String = ""
    @Published private(set) var completions: [String] = []

    init() {
        $text
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { text -> [String] in
                let components = text.components

                if components.count == 2, text.hasSuffix("(") {
                    return [text + ")"]
                }

                let lastComponent = (components.last ?? "")
                    .debugDescription
                    .trimmingCharacters(
                        in: CharacterSet(["\""])
                    )
                return Interpreter.complete(lastComponent)
            }
            .assign(to: &$completions)
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
        Task {
            let code = text
            text = ""
            completions = []

            await Interpreter.asyncRun(code)
        }
    }

    func returnPressed() -> Bool {
        guard let last = text.last else {
            return false
        }

        let lines = text.components(separatedBy: .newlines)

        if lines.count == 1 {
            // These special characters breaks it to new lines.
            if ":({[".contains(last) || lines[0] == "@" {
                return false
            }

            return true
        }

        if last == "\n" {
            return true
        }

        return false
    }
}

extension String {
    var components: [String] {
        let set = CharacterSet.whitespacesAndNewlines
            .union(CharacterSet(["(", "["]))
        return components(separatedBy: set)
    }
    
    var lastComponent: String {
        let set = CharacterSet.whitespacesAndNewlines
            .union(CharacterSet(["(", "["]))
        return components(separatedBy: set).last ?? ""
    }
}
