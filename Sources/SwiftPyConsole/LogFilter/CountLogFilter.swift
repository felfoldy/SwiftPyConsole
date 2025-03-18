//
//  CountLogFilter.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-03-18.
//

import DebugTools

struct CountLogFilter: LogFilter {
    let count: Int

    func apply(logs: [any PresentableLog]) -> [any PresentableLog] {
        logs.suffix(count)
    }
}

extension LogFilter where Self == CountLogFilter {
    static func count(_ value: Int) -> CountLogFilter {
        CountLogFilter(count: value)
    }
}
