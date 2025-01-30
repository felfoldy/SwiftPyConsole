// The Swift Programming Language
// https://docs.swift.org/swift-book

import DebugTools
import SwiftUI

@MainActor
public final class SwiftPyConsole {
    public static let store = PythonLogStore()
    
    @available(iOS 17.0, *)
    public static func initialize() {
        DebugTools.initialize(store: store)
        
        #if os(iOS)
        DebugTools.shakePresentedConsole = {
            let view = GeometryReader { proxy in
                let isPresented = proxy.size.height > 44
                
                Group {
                    if isPresented {
                        PythonConsoleView()
                            .safeAreaInset(edge: .top, spacing: 0) {
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .frame(height: 20)
                            }
                    } else {
                        Text(">>>")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .padding(8)
                            .background(.thinMaterial)
                    }
                }.animation(.default, value: isPresented)
            }
            
            return ConsoleViewController(base: UIHostingController(rootView: view))
        }
        #endif
    }
}
