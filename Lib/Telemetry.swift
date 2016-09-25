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
}

class Telemetry {
    enum Stage {
        case Unknown
        case WaitingForGame
        case Connected
    }

    enum Game {
        case Unknown
        case F12016
        case DirtRally
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
                        var pointer = UnsafeMutableRawPointer.allocate(bytes: 1024*1024, alignedTo: 0)
                        let len = UDPRead(self.ld, &pointer)
                        if len == 264 {
                            self.game = .DirtRally
                        } else {
                            self.game = .F12016
                        }

                        self.stage = .Connected
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
                        default:
                            print("Telemetry game == unknown!")
                            return
                        }
                    default:
                        print("Telemetry stage == unknown!")
                        return
                    }
                }
            }
        }
    }

    func readF1Packet() -> F1UDPPacket? {
        var packet = F1UDPPacket()
        return UDPRead(self.ld, &packet) != 0 ? packet : nil
    }

    func readDirtRallyPacket() -> DirtRallyPacket? {
        var packet = DirtRallyPacket()
        return UDPRead(self.ld, &packet) != 0 ? packet : nil
        /*
        // TODO: fix number
        return self.readPacket(ref: &packet, timeout: 99.0) ? packet : nil
 */
    }

    private func readPacket(ref: UnsafeMutableRawPointer, timeout: TimeInterval) -> Bool {
        sockQueue.addOperation {
            UDPRead(self.ld, ref)
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        while sockQueue.operationCount != 0 && CFAbsoluteTimeGetCurrent() - startTime < 1.0 {
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }

        return sockQueue.operationCount == 0
    }
}
