//
//  NIClient.swift
//  NearbyInteractionDemo
//
//  Created by Shingai Yoshimi on 2021/03/12.
//

import Foundation
import Combine
import ComposableArchitecture
import NearbyInteraction

struct NIClient {
    var setup: (AnyHashable) -> Effect<NIClient.Action, NIClient.Error>
    var run: (Data, AnyHashable) -> NIDiscoveryToken

    enum Action: Equatable {
        case send(Data)
        case onUpdateNearbyObjects([NINearbyObject])
        case onRemoveNearbyObjects([NINearbyObject])
    }

    enum Error: Swift.Error, Equatable {
    }
}

private var dependencies: [AnyHashable: NIDependencies] = [:]

extension NIClient {
    static let live = NIClient(
        setup: { id in
            Effect.run { subscriber in
                let cancellable = AnyCancellable {
                    stopDependencies(id: id)
                }

                let sessionDelegate = SessionDelegate(
                    onUpdate: { subscriber.send(.onUpdateNearbyObjects($0)) },
                    onRemove: { subscriber.send(.onRemoveNearbyObjects($0)) }
                )
                let session = NISession()
                session.delegate = sessionDelegate

                dependencies[id] = NIDependencies(
                    session: session,
                    sessionDelegate: sessionDelegate
                )

                guard
                    let discoveryToken = session.discoveryToken,
                    let data = try?  NSKeyedArchiver.archivedData(withRootObject: discoveryToken, requiringSecureCoding: true)
                else {
                    fatalError("failed to prepare discovery token.")
                }
                subscriber.send(.send(data))

                return cancellable
            }
        },
        run: { data, id in
            guard let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) else {
                fatalError("Unexpectedly failed to decode discovery token.")
            }
            let config = NINearbyPeerConfiguration(peerToken: discoveryToken)
            let session = dependencies[id]?.session
            session?.run(config)
            return discoveryToken
        }
    )
}

private extension NIClient {
    static func stopDependencies(id: AnyHashable) {
        dependencies[id] = nil
    }
}

private struct NIDependencies {
    let session: NISession
    let sessionDelegate: NISessionDelegate
}

private class SessionDelegate: NSObject, NISessionDelegate {
    let onUpdate: ([NINearbyObject]) -> Void
    let onRemove: ([NINearbyObject]) -> Void

    init(
        onUpdate: @escaping ([NINearbyObject]) -> Void,
        onRemove: @escaping ([NINearbyObject]) -> Void
    ) {
        self.onUpdate = onUpdate
        self.onRemove = onRemove
    }

    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        onUpdate(nearbyObjects)
    }

    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        onRemove(nearbyObjects)
    }
}
