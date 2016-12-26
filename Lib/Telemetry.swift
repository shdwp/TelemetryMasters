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
        case PCars = 1367
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
                while true { autoreleasepool {
                    switch self.stage {
                    case .WaitingForGame:
                        var packet = sTelemetryData()
                        let len = UDPRead(self.ld, &packet)
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
                        case .PCars:
                            if let packet = self.readPCarsPacket() {
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
                    } }
                }
            }
        }
    }

    func forceConnected(game: Game) {
        self.game = game
        self.stage = .Connected
    }

    var __last = 0.0
    func readF1Packet() -> F1UDPPacket? {
        var packet = F1UDPPacket()
        return self.waitForSocket {
            UDPRead(self.ld, &packet)
        } ? packet : nil
    }

    func readDirtRallyPacket() -> DirtRallyPacket? {
        var packet = DirtRallyPacket()
        return self.waitForSocket {
            UDPRead(self.ld, &packet)
        } ? packet : nil
    }

    func readPCarsPacket() -> sTelemetryData? {
        var packet = sTelemetryData()
        //return self.waitForSocket {
        var __wait = CFAbsoluteTimeGetCurrent()
        UDPRead(self.ld, &packet)
        print("Got packet in ", CFAbsoluteTimeGetCurrent() - __wait)
        __last = CFAbsoluteTimeGetCurrent()
        return packet
        //} ? packet : nil
    }


    private func waitForSocket(_ operation: @escaping () -> ()) -> Bool {
        self.sockQueue.addOperation(operation)

        let startTime = CFAbsoluteTimeGetCurrent()
        let timeout = 15.0
        while sockQueue.operationCount != 0 && CFAbsoluteTimeGetCurrent() - startTime < timeout {
            Thread.sleep(forTimeInterval: 0.001)
        }

        return sockQueue.operationCount == 0
    }
}
