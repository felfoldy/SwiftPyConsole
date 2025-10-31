//
//  Console.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-10-28.
//

import SwiftPy
import Foundation

@MainActor
@Observable
@Scriptable
final class Console {
    internal static let shared = Console()
    internal var previewURL: URL?
    
    internal init() {
        toPython(.main.emplace("console"))
    }
    
    func preview(url: String) throws {
        guard let url = URL(string: url) else {
            throw PythonError.ValueError("Not a valid URL: \(url)")
        }
        previewURL = url
    }
}
