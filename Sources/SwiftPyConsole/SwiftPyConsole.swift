// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import SwiftPy
import LogTools

let log = Logger(subsystem: "com.felfoldy.SwiftPyConsole", category: "SwiftPyConsole")

@MainActor
public final class SwiftPyConsole {
    public static let store = PythonLogStore(logFilter: .none)

    static var isInited: Bool = false

    public static func initialize(presentByShaking: Bool = false) {
        if isInited { return }

        if !EnvironmentValues().supportsMultipleWindows {
            Console.shared.isShakePresentationEnabled = presentByShaking
        }

        Logger.destinations.append(store)
        Interpreter.output = store
        store.logFilter = .count(200)

        Interpreter.main.bind("clear() -> None") { _, _ in
            PyAPI.returnNone {
                SwiftPyConsole.store.logs.removeAll()
            }
        }

        #if os(macOS)
        // Remove weird substitution on mac.
        UserDefaults.standard.set(false, forKey: "NSAutomaticQuoteSubstitutionEnabled")
        UserDefaults.standard.set(false, forKey: "NSAutomaticDashSubstitutionEnabled")
        UserDefaults.standard.set(false, forKey: "NSAutomaticTextReplacementEnabled")
        UserDefaults.standard.set(false, forKey: "NSAutomaticSpellingCorrectionEnabled")
        #endif
        
        isInited = true
    }
}

#if canImport(UIKit) && !os(visionOS)
import UIKit

extension UIWindow {
    open override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        guard motion == .motionShake else { return }
        guard Console.shared.isShakePresentationEnabled else { return }
        try? Console.shared.show()
    }
}
#endif
