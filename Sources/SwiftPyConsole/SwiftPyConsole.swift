// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import SwiftPy
import LogTools

let log = Logger(subsystem: "com.felfoldy.SwiftPyConsole", category: "SwiftPyConsole")

@MainActor
public final class SwiftPyConsole {
    public static let store = PythonLogStore(logFilter: .none)
    public static var isShakePresentationEnabled = false

    static var isInited: Bool = false

    public static func initialize(presentByShaking: Bool = true) {
        if isInited { return }

        isShakePresentationEnabled = presentByShaking
        
        Logger.destinations.append(store)
        Interpreter.output = store
        store.logFilter = .count(200)
        
        // TODO: Implement to in the interpreter?
        Interpreter.main.bind(#def("clear") {
            SwiftPyConsole.store.logs.removeAll()
        })
        
        #if os(iOS)
        if isShakePresentationEnabled {
            log.notice("Console initialized. Present it by shaking the device.")
        }
        #endif
        
        isInited = true
    }
}

#if canImport(UIKit) && !os(visionOS)
import UIKit

extension SwiftPyConsole {
    public static func show() {
        guard SwiftPyConsole.isShakePresentationEnabled else { return }
        
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
    }
}

extension UIWindow {
    open override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }

        SwiftPyConsole.show()
    }
}
#endif
