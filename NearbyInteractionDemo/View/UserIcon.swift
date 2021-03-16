//
//  UserIcon.swift
//  NearbyInteractionDemo
//
//  Created by Shingai Yoshimi on 2021/03/12.
//

import SwiftUI

struct UserIcon: View {
    let user: User

    init(_ user: User) {
        self.user = user
    }

    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Image(user.icon)
                .resizable()
                .frame(width: 50, height: 50)
            Text(user.displayName)
                .font(.caption)
        }
    }
}

struct UserIcon_Previews: PreviewProvider {
    static var previews: some View {
        UserIcon(User(displayName: "hoge"))
            .previewLayout(.fixed(width: 100, height: 100))
    }
}
