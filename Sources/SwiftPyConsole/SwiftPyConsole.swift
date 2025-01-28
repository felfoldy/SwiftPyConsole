// The Swift Programming Language
// https://docs.swift.org/swift-book

import DebugTools

@MainActor
public final class SwiftPyConsole {
    public static let store = PythonLogStore()
    
    public static func initialize() {
        DebugTools.initialize(store: store)
    }
}
