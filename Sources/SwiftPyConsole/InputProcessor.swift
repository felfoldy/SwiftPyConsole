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
    @Published var input: String = ""
    @Published var selectedCompletion: String?
    @Published private(set) var completions: [String] = []
    @Published private(set) var replBuffer: [String] = []
    
    init() {
        $input
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { text -> [String] in
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
        let lastComponent = input.lastComponent
        input = input.dropLast(lastComponent.count) + completion
    }
    
    func submit() {
        Interpreter.input(input)
        input = ""
        completions = []
        replBuffer = Interpreter.shared.replLines
    }
}

extension String {
    var lastComponent: String {
        let set = CharacterSet.whitespacesAndNewlines
            .union(CharacterSet(["(", "["]))
        return components(separatedBy: set).last ?? ""
    }
}
