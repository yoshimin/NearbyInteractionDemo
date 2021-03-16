//
//  NeighborsView.swift
//  NearbyInteractionDemo
//
//  Created by Shingai Yoshimi on 2021/03/15.
//

import SwiftUI

struct NeighborsView: View {
    let icons: [NearbyUserIcon]

    init(_ icons: [NearbyUserIcon]) {
        self.icons = icons
    }

    var body: some View {
        ZStack {
            ForEach(icons, id: \.self) { icon in
                UserIcon(icon.user)
                    .offset(x: icon.offset.x, y: icon.offset.y)
            }
        }
    }
}

struct NeighborsView_Previews: PreviewProvider {
    static var previews: some View {
        NeighborsView([
            NearbyUserIcon(
                user: User(displayName: "hoge"),
                offset: NearbyUserIcon.Offset(x: 70, y: 200)
            ),
            NearbyUserIcon(
                user: User(displayName: "fuga"),
                offset: NearbyUserIcon.Offset(x: -100, y: -100)
            ),
        ])
    }
}
