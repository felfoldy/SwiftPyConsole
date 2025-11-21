//
//  Console.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-10-28.
//

import SwiftPy
import Foundation
import SwiftUI

@MainActor
@Observable
@Scriptable
final class Console {
    internal static let shared = Console()
    
    var isShakePresentationEnabled: Bool = false
    
    var isPresented: Bool {
        _isPresented
    }
    
    internal var previewURL: URL?
    internal var _isPresented = false

    internal init() {
        toPython(.main.emplace("console"))
    }
    
    func preview(url: String) throws {
        guard let url = URL(string: url) else {
            throw PythonError.ValueError("Not a valid URL: \(url)")
        }
        previewURL = url
    }
    
    func show() throws {
        if isPresented {
            throw PythonError.AssertionError("Console is already presented.")
        }

        let env = EnvironmentValues()
        
        if env.supportsMultipleWindows {
            env.openWindow(id: "console")
            return
        }

        #if os(iOS)
        let view = PythonConsoleView()
            .safeAreaInset(edge: .top, spacing: 0) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 20)
            }

        let vc = PythonConsoleViewController(base: UIHostingController(rootView: view))
        
        UIWindow.keyWindow?.rootViewController?
            .topMostViewController
            .present(vc, animated: true)
        #endif
    }
}
