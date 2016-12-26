//
//  PCarsViewController.swift
//  TelemetryMasters
//
//  Created by shdwprince on 12/24/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import Foundation
import UIKit

class PCarsViewController: TelemetryViewerController {
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
            self.speedLabel.font = self.speedLabel.font.withSize(120)
            self.secondaryLabel.font = self.secondaryLabel.font.withSize(112)
            self.mainLabel.font = self.mainLabel.font.withSize(48)
        }

        self.mainLabelFont = self.mainLabel.font
        self.mainLabelBoldFont = UIFont(name: "Menlo-Bold", size: self.mainLabelFont.pointSize)

        self.revCounterHideConstraint.isActive = !Settings.F1.showRevCounter()
        self.revCounterView.type = Settings.F1.revCounterType()
    }

    override func telemetryDidGetPacket(_ packet: Any, instance: Telemetry) {
        let x = packet as! sTelemetryData
        if x.sViewedParticipantIndex != 0 {
            return
        }
        
        self.queueUiUpdate {
            guard self.revCounterView != nil else { return }

            self.renderRevInMode(packet: x)
            //self.renderGaugesInMode(packet: x)
            self.renderLabelsInMode(packet: x)
        }
    }

    func renderRevInMode(packet x: sTelemetryData) {
        let before = 0.807 * Float(x.sMaxRpm)
        let beyond = 0.0 * Float(x.sMaxRpm)
        let progress = (Float(x.sRpm) - before) / (Float(x.sMaxRpm) - beyond - before)
        
        self.revCounterView.setRevLight(progress: progress, drsLight: false)

        if progress > 0.95 {
            self.revCounterView.blinkLights(from: RevCounterView.Light.firstRev, to: RevCounterView.Light.lastRev, interval: 0.1)
        }
    }

    func renderLabelsInMode(packet x: sTelemetryData) {
        switch Int(x.sGearNumGears) {
        case 0:
            self.gearLabel.text = "R"
        case 1:
            self.gearLabel.text = "N"
        default:
            self.gearLabel.text = "\(Int(x.sGearNumGears - 1))"
        }

        let speedCoef: Float = 3.6
        self.speedLabel.text = String(format: "%03.0f", x.sSpeed * speedCoef)

        //self.positionLabel.text = "P\(Int(x.m_car_position+1)) L\(Int(x.m_lap+1))"
        /*
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
         */

    }
}
