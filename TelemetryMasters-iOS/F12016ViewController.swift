//
//  ViewController.swift
//  TelemetryMasters-iOS
//
//  Created by shdwprince on 9/22/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import UIKit

struct LapStats {
    typealias DistanceId = Float

    var times: [DistanceId: Float] = [:]
    let startTime = CFAbsoluteTimeGetCurrent()

    init() {
    }

    mutating func setTime(identifier: DistanceId, time: Float) {
        if !self.times.keys.contains(identifier) {
            self.times[identifier] = time
        }
    }

    mutating func setTime(distance: Float, time: Float) {
        self.setTime(identifier: self.distanceIdentifier(distance), time: time)
    }

    subscript (distance: Float) -> Float? {
        return self.times[self.distanceIdentifier(distance)]
    }

    func distanceIdentifier(_ distance: Float) -> DistanceId {
        return floor(distance / 10)
    }

    func totalTime() -> Float {
        return self.times.values.max() ?? 0.0
    }
}

extension F1UDPPacket {
    enum SessionType {
        case Unknown
        case Practice
        case Qualifying
        case Race

        init(_ x: Float) {
            switch x {
            case 1.0:
                self = .Practice
            case 2.0:
                self = .Qualifying
            case 3.0:
                self = .Race
            default:
                self = .Unknown
            }
        }
    }

    func tickStats() -> (Bool, SessionType) {
        return (self.m_in_pits == 1.0, SessionType(self.m_sessionType))
    }

    var sessionType: SessionType {
        return SessionType(self.m_sessionType)
    }
}

class F12016ViewController: TelemetryViewerController {

    @IBOutlet weak var revCounterView: RevCounterView!
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var gearLabel: UILabel!

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!

    @IBOutlet weak var tyreStatusView: TyreStatus!
    @IBOutlet weak var fuelGauge: PlainGauge!
    @IBOutlet weak var fuelLabel: UILabel!
    @IBOutlet weak var revCounterHideConstraint: NSLayoutConstraint!
    
    private var fuelMax: Float = 0
    private var pitStatus: Float = -1

    private var lastPacket = F1UDPPacket()
    private var lapStats = LapStats(), referenceLapStats: LapStats?, lastLastLapStats: LapStats?

    private var mainLabelFont: UIFont!, mainLabelBoldFont: UIFont!

    override func viewDidAppear(_ animated: Bool) {
        self.revCounterView.setNeedsDisplay()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let height = max(UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width)

        if height <= 480 {
            self.speedLabel.font = self.speedLabel.font.withSize(48)
            self.secondaryLabel.font = self.secondaryLabel.font.withSize(56)
            self.mainLabel.font = self.mainLabel.font.withSize(48)
        } else if height <= 568 {
            self.speedLabel.font = self.speedLabel.font.withSize(96)
            self.secondaryLabel.font = self.secondaryLabel.font.withSize(72)
            self.mainLabel.font = self.mainLabel.font.withSize(48)
        } else if height == 736 {
            self.speedLabel.font = self.speedLabel.font.withSize(128)
            self.secondaryLabel.font = self.secondaryLabel.font.withSize(112)
            self.mainLabel.font = self.mainLabel.font.withSize(48)
        }

        self.mainLabelFont = self.mainLabel.font
        self.mainLabelBoldFont = UIFont(name: "Menlo-Bold", size: self.mainLabelFont.pointSize)

        self.revCounterHideConstraint.isActive = !Settings.F1.showRevCounter()
        self.revCounterView.type = Settings.F1.revCounterType()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func telemetryDidGetPacket(_ packet: Any, instance: Telemetry) {
        let x = packet as! F1UDPPacket

        if x.tickStats() != self.lastPacket.tickStats() {
            self.fuelMax = x.m_fuel_in_tank
            self.lapStats = LapStats()
            self.referenceLapStats = nil
        }

        if x.m_lap > self.lastPacket.m_lap {
            switch x.sessionType {
            case .Race:
                self.lastLastLapStats = self.referenceLapStats
                self.referenceLapStats = self.lapStats
            default:
                if let referenceLapStats = self.referenceLapStats, referenceLapStats.totalTime() < self.lapStats.totalTime() {
                    self.lastLastLapStats = self.referenceLapStats
                    self.referenceLapStats = self.lapStats
                }
            }

            self.lapStats = LapStats()
        }

        self.lapStats.setTime(distance: x.m_lapDistance, time: x.m_lapTime)
        self.lastPacket = x

        self.queueUiUpdate {
            guard self.revCounterView != nil else { return }
            
            if self.fuelMax < x.m_fuel_in_tank {
                self.fuelMax = x.m_fuel_in_tank
            }

            self.renderRevInMode(packet: x)
            self.renderGaugesInMode(packet: x)
            self.renderLabelsInMode(packet: x)
        }
    }

    func renderRevInMode(packet x: F1UDPPacket) {
        let before = 0.807 * x.m_max_rpm
        let beyond = 0.137 * x.m_max_rpm
        let progress = (x.m_engineRate - before) / (x.m_max_rpm - beyond - before)
        
        let drsLight = x.m_drsAllowed == 1 || x.m_drs == 1
        
        self.revCounterView.setRevLight(progress: progress, drsLight: drsLight)

        if drsLight {
            self.revCounterView.setLight(at: .drs, true)
        }

        if progress > 0.95 {
            self.revCounterView.blinkLights(from: RevCounterView.Light.firstRev, to: RevCounterView.Light.lastRev, interval: 0.1)
        }

        if x.m_drsAllowed == 1 {
            self.revCounterView.blinkLight(at: .drs, interval: 0.8)
        }
    }

    func renderGaugesInMode(packet x: F1UDPPacket) {
        let latMultiplier: Float = 10, lonMultiplier: Float = 5, suspMultiplier: Float = 2
        self.tyreStatusView.force = TyreStatus.Force(lat: x.m_gforce_lat * latMultiplier, lon: x.m_gforce_lon * lonMultiplier)
        self.tyreStatusView.suspPosition = [x.m_susp_pos_fl * suspMultiplier, x.m_susp_pos_fr * suspMultiplier, x.m_susp_pos_bl * suspMultiplier, x.m_susp_pos_br * suspMultiplier, ]
        self.tyreStatusView.suspPositionMax = 15*2
        self.tyreStatusView.setNeedsDisplay()
        
        self.fuelGauge.progress = x.m_fuel_in_tank / self.fuelMax
        self.fuelGauge.setNeedsDisplay()
    }

    func renderLabelsInMode(packet x: F1UDPPacket) {
        switch Int(x.m_gear) {
        case 0:
            self.gearLabel.text = "R"
        case 1:
            self.gearLabel.text = "N"
        default:
            self.gearLabel.text = "\(Int(x.m_gear - 1))"
        }

        let speedCoef: Float = 3.6
        self.speedLabel.text = String(format: "%03.0f", x.m_speed * speedCoef)

        if (self.lastPacket.sessionType == .Race) {
            self.positionLabel.text = "P\(Int(x.m_car_position+1)) L\(Int(x.m_lap+1))"
        } else {
            self.positionLabel.text = "L\(Int(x.m_lap+1))"
        }

        self.fuelLabel.text = String(format:"%.0flb", x.m_fuel_in_tank)

        var delta: Float?
        if CFAbsoluteTimeGetCurrent() - self.lapStats.startTime < 3.0 {
            self.mainLabel.font = self.mainLabelBoldFont
            self.mainLabel.text = self.formatTime(x.m_last_lap_time)

            if let lastLastTime = self.lastLastLapStats?.totalTime() {
                delta = x.m_last_lap_time - lastLastTime
            }
        } else {
            self.mainLabel.text = self.formatTime(x.m_lapTime)
            self.mainLabel.font = self.mainLabelFont

            if let lastTime = self.referenceLapStats?[x.m_lapDistance],
               let currentTime = self.lapStats[x.m_lapDistance] {
                delta = currentTime - lastTime
            }
        }

        if let delta = delta {
            self.secondaryLabel.text = String.init(format: "%02.3f", delta)
            self.secondaryLabel.textColor = delta <= 0 ? UIColor.green : UIColor.red
        } else {
            self.secondaryLabel.text = "---"
            self.secondaryLabel.textColor = UIColor.white
        }
        
    }


}

