//
//  Telemetry.swift
//  TelemetryMasters
//
//  Created by shdwprince on 9/23/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import Foundation

protocol TelemetryDelegate: class {
    func telemetryDidProceedTo(_ stage: Telemetry.Stage, instance: Telemetry)
    func telemetryDidGetPacket(_ packet: Any, instance: Telemetry)
    func telemetryDidEncounterError(_ error: NSError, instance: Telemetry)
}

class Telemetry {
    enum Stage {
        case Unknown
        case WaitingForGame
        case Connected
    }

    enum Error: Int {
        case Unknown = 0
        case UnknownGame = 1

        init(_ raw: Int) {
            if let error = Error(rawValue: raw) {
                self = error
            } else {
                self = .Unknown
            }
        }
    }

    enum Game: Int {
        case Unknown = -1
        case F12016 = 280
        case DirtRally = 264
    }

    var delegates: [TelemetryDelegate] = []
    var game: Game = .Unknown

    private let queue = OperationQueue(), sockQueue = OperationQueue()
    private var ld: Int32 = 0
    private let port: UInt16

    private var stageIdentifier: Stage = .Unknown
    private var stage: Stage {
        set {
            stageIdentifier = newValue
            delegates.forEach { (d) in
                d.telemetryDidProceedTo(newValue, instance: self)
            }
        }

        get {
            return stageIdentifier
        }
    }

    init(port: UInt16) {
        self.port = port
    }

    func addDelegate(_ d: TelemetryDelegate) {
        delegates.append(d)
    }

    func removeDelegate(_ d: TelemetryDelegate) {
        let idx = delegates.index { (l) -> Bool in
            return d === l
        }

        if let idx = idx {
            delegates.remove(at: idx)
        }
    }

    func startServer() {
        ld = UDPSock(port)

        if ld > 0 {
            self.stage = .WaitingForGame
            queue.addOperation {
                while true {
                    switch self.stage {
                    case .WaitingForGame:
                        let len = UDPPeek(self.ld)
                        if let game = Game(rawValue: len) {
                            self.game = game
                            self.stage = .Connected
                        } else {
                            self.delegates.forEach({ (d) in
                                d.telemetryDidEncounterError(NSError.init(domain: "", code: Error.UnknownGame.rawValue, userInfo: nil), instance: self)
                            })

                            self.stage = .Unknown
                        }
                    case .Connected:
                        switch self.game {
                        case .F12016:
                            if let packet = self.readF1Packet() {
                                self.delegates.forEach({ (d) in
                                    d.telemetryDidGetPacket(packet, instance: self)
                                })
                            } else {
                                self.stage = .WaitingForGame
                            }
                        case .DirtRally:
                            if let packet = self.readDirtRallyPacket() {
                                self.delegates.forEach({ (d) in
                                    d.telemetryDidGetPacket(packet, instance: self)
                                })
                            } else {
                                self.stage = .WaitingForGame
                            }
                        default: return
                        }
                    default:
                        Thread.sleep(forTimeInterval: 1.0)
                    }
                }
            }
        }
    }

    func forceConnected(game: Game) {
        self.game = game
        self.stage = .Connected
    }

    func readF1Packet() -> F1UDPPacket? {
        var packet = F1UDPPacket()
        return self.readPacket(ref: &packet, timeout: 1.0) ? packet : nil
    }

    func readDirtRallyPacket() -> DirtRallyPacket? {
        var packet = DirtRallyPacket()
        return self.readPacket(ref: &packet, timeout: 1.0) ? packet : nil
    }

    private func readPacket(ref: UnsafeMutableRawPointer, timeout: TimeInterval) -> Bool {
        sockQueue.addOperation {
            UDPRead(self.ld, ref)
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        while sockQueue.operationCount != 0 && CFAbsoluteTimeGetCurrent() - startTime < timeout {
            Thread.sleep(forTimeInterval: 0.01)
        }

        return sockQueue.operationCount == 0
    }
}
