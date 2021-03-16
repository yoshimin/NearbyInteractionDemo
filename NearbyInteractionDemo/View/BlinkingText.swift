//
//  BlinkingText.swift
//  NearbyInteractionDemo
//
//  Created by Shingai Yoshimi on 2021/03/12.
//

import SwiftUI

struct BlinkingText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .padding()
            .blink()
    }
}

struct BlinkingText_Previews: PreviewProvider {
    static var previews: some View {
        BlinkingText("hogehoge...")
            .previewLayout(.fixed(width: 200, height: 100))
    }
}
