//
//  RemoteConsoleConnection.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2026-02-23.
//

import SwiftPy
import Foundation

@MainActor
class RemoteConsoleConnection {
    let peer = Peer(name: "console")
    
    init(target: String) {
        peer.autoconnect(name: target)
        peer.messageReceived { data in
            guard let str = String(data: data, encoding: .utf8) else {
                return
            }

            if str.starts(with: "[STDIN]") {
                SwiftPyConsole.store.input(String(str.dropFirst(7)))
            }
            
            if str.starts(with: "[STDOUT]") {
                SwiftPyConsole.store.stdout(String(str.dropFirst(8)))
            }
            
            if str.starts(with: "[STDERR]") {
                SwiftPyConsole.store.stderr(String(str.dropFirst(8)))
            }

            if str.starts(with: "[TIME]"), let time = UInt64(str.dropFirst(6)) {
                SwiftPyConsole.store.executionTime(time)
            }
        }
    }

    func run(_ code: String) {
        try? peer.send(data: Data("[RUN]\(code)".utf8))
    }
}
