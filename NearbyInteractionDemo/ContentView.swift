//
//  ContentView.swift
//  NearbyInteractionDemo
//
//  Created by Shingai Yoshimi on 2021/03/11.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<State, Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                if (!viewStore.isSearchingLabelHidden) {
                    BlinkingText("Searching...")
                }
                if (!viewStore.isCurrentUserHidden) {
                    ZStack {
                        UserIcon(viewStore.currentUser)
                        NeighborsView(viewStore.nearbyUserIcons)
                    }
                }
            }
            .onAppear{ viewStore.send(.onAppear) }
        }

    }
}
