//
//  Blink.swift
//  NearbyInteractionDemo
//
//  Created by Shingai Yoshimi on 2021/03/12.
//

import SwiftUI

extension View {
    func blink() -> some View {
        modifier(
            Blink()
        )
    }
}

struct Blink: ViewModifier {
    @SwiftUI.State var opacity = 1.0

    private let duration = 1.0

    private var blinking: Binding<Double> {
            Binding<Double>(get: {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.$opacity.wrappedValue = 0
                }
                return self.$opacity.wrappedValue

            }, set: {
                self.$opacity.wrappedValue = $0
            })
        }

    func body(content: Content) -> some View {
        content
            .opacity(blinking.wrappedValue)
            .animation(
                Animation.easeOut(duration: duration).repeatForever()
            )
    }
}
