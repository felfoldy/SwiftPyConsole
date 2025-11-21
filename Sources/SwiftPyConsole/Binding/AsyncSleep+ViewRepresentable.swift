//
//  AsyncSleep+ViewRepresentable.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-11-01.
//

import SwiftPy
import SwiftUI
import DebugTools

extension AsyncSleep: @retroactive ViewRepresentable {
    public struct Content: RepresentationContent {
        @State public var model: AsyncSleep
        
        public init(model: AsyncSleep) {
            self.model = model
        }

        public var body: some View {
            LogContainerView(tint: .indigo) {
                TimelineView(.animation) { context in
                    let interval = max(
                        0,
                        model.startDate
                            .addingTimeInterval(model.seconds)
                            .timeIntervalSince(context.date)
                    )
                    
                    HStack {
                        Image(systemName: "clock")
                        
                        Text(
                            Date(timeIntervalSinceReferenceDate: interval),
                            format: .dateTime.minute().second()
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    @Previewable @State var sleep = AsyncSleep(seconds: 5)

    ScrollView {
        AsyncSleep.Content(model: sleep)
            .frame(maxWidth: .infinity)
    }
}
