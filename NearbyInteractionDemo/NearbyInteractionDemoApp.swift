//
//  NearbyInteractionDemoApp.swift
//  NearbyInteractionDemo
//
//  Created by Shingai Yoshimi on 2021/03/11.
//

import SwiftUI
import ComposableArchitecture

@main
struct NearbyInteractionDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store<State, Action>(
                    initialState: State(),
                    reducer: reducer.debug(),
                    environment: Environment(
                        mpcCliennt: .live,
                        niClient: .live,
                        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                    )
                )
            )
        }
    }
}
