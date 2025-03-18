//
//  WindowSupport.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-03-19.
//

import SwiftUI

public struct DebugWindowGroup<Content: View>: Scene {
    @Environment(\.openWindow) private var openWindow
    
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        SwiftPyConsole.initialize()
        self.content = content()
    }
    
    public var body: some Scene {
        WindowGroup {
            content
        }
        .commands {
            CommandMenu("Debug") {
                Button("Show Console") {
                    openWindow(id: "console")
                }
                .keyboardShortcut("d", modifiers: .command)
            }
        }
    }
}

public struct ConsoleWindow: Scene {
    public init() {}
    
    public var body: some Scene {
        #if os(macOS)
        Window("Console", id: "console") {
            PythonConsoleView()
        }
        #else
        WindowGroup(id: "console") {
            PythonConsoleView()
                .navigationTitle("Console")
                .navigationBarTitleDisplayMode(.inline)
        }
        #endif
    }
}
