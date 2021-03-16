//
//  Core.swift
//  NearbyInteractionDemo
//
//  Created by Shingai Yoshimi on 2021/03/11.
//

import SwiftUI
import ComposableArchitecture
import MultipeerConnectivity
import NearbyInteraction
import simd

struct User: Equatable, Hashable {
    let icon = "icon\(Int.random(in: 1 ... 4))"
    let displayName: String
}

struct NearbyPeer: Equatable, Hashable {
    let user: User
    let token: NIDiscoveryToken
}

struct NearbyObject: Equatable, Hashable {
    let peer: NearbyPeer
    let distance: Float
    let direction: simd_float3
}

struct NearbyUserIcon: Equatable, Hashable {
    struct Offset: Equatable, Hashable {
        let x: CGFloat
        let y: CGFloat
    }
    let user: User
    let offset: Offset
}

struct State: Equatable {
    let currentUser = User(displayName: UIDevice.current.name)
    var isSearchingLabelHidden = true
    var isCurrentUserHidden = true
    var connectedPeers: [NearbyPeer] = []
    var nearbyObjects: [NearbyObject] = []
    var nearbyUserIcons: [NearbyUserIcon] {
        nearbyObjects.map {
            let x = UIScreen.main.bounds.width * 0.5 * CGFloat($0.direction.x)
            let y = UIScreen.main.bounds.height * 0.5 * CGFloat($0.direction.y) * -1
            let offset = NearbyUserIcon.Offset(x: CGFloat(x), y: CGFloat(y))
            return NearbyUserIcon(user: $0.peer.user, offset: offset)
        }
    }
}

enum Action: Equatable {
    case onAppear
    case mpc(Result<MPCClient.Action, MPCClient.Error>)
    case ni(Result<NIClient.Action, NIClient.Error>)
}

struct Environment {
    let mpcCliennt: MPCClient
    let niClient: NIClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let reducer = Reducer<State, Action, Environment> { state, action, env in
    struct MPCId: Hashable {}
    struct NIId: Hashable {}

    switch action {
    case .onAppear:
        state.isSearchingLabelHidden = false
        return env.mpcCliennt
            .start(state.currentUser.displayName, MPCId())
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(Action.mpc)

    case let .mpc(.success(.onConnect(peerId))):
        state.isSearchingLabelHidden = true
        state.isCurrentUserHidden = false
        return env.niClient
            .setup(NIId())
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(Action.ni)

    case let .mpc(.success(.onDisconnect(peerId))):
        return .none

    case let .mpc(.success(.onReceive(data, peerId))):
        let token = env.niClient.run(data, NIId())
        state.connectedPeers.append(NearbyPeer(user: User(displayName: peerId.displayName), token: token))
        return .none

    case .mpc(.failure(_)):
        return .none

    case let .ni(.success(.send(data))):
        env.mpcCliennt.send(data, MPCId())
        return .none

    case let .ni(.success(.onUpdateNearbyObjects(objects))):
        state.nearbyObjects = objects.compactMap{ nearbyObject in
            guard
                let peer = state.connectedPeers.first(where: { $0.token == nearbyObject.discoveryToken }),
                let distance = nearbyObject.distance,
                let direction = nearbyObject.direction
            else {
                return nil
            }
            return NearbyObject(peer: peer, distance: distance, direction: direction)
        }
        return .none

    case let .ni(.success(.onRemoveNearbyObjects(objects))):
        objects.forEach { nearbyObject in
            state.nearbyObjects.removeAll(where: { $0.peer.token == nearbyObject.discoveryToken })
        }
        return .none

    case .ni(.failure(_)):
        return .none
    }
}
