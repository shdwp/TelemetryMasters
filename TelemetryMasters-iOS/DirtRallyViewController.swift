//
//  DirtRallyViewController.swift
//  TelemetryMasters
//
//  Created by shdwprince on 9/23/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import Foundation
import UIKit

class DirtRallyViewController: TelemetryViewerController {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tyreStatusView: TyreStatus!
    @IBOutlet weak var rpmCounterView: RallyRPMCounter!
    @IBOutlet weak var throttleCounterView: RallyRPMCounter!
    @IBOutlet weak var gearLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var progressGauge: PlainGauge!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.progressGauge.delimetersCount = Settings.DirtRally.numberOfSectors()
    }

    override func telemetryDidGetPacket(_ packet: Any, instance: Telemetry) {
        let x = packet as! DirtRallyPacket
        self.queueUiUpdate {
            guard self.rpmCounterView != nil else { return }

            switch Int(x.m_gear) {
            case 10:
                self.gearLabel.text = "R"
            case 0:
                self.gearLabel.text = "N"
            default:
                self.gearLabel.text = "\(Int(x.m_gear))"
            }
            
            self.speedLabel.text = "\(Int(x.m_speed * 3.6))"
            self.timeLabel.text = self.formatTime(x.m_lapTime)
            
            self.throttleCounterView.progress = CGFloat(x.m_throttle)
            self.throttleCounterView.setNeedsDisplay()
            
            self.rpmCounterView.progress = CGFloat(x.m_engineRate / x.m_max_rpm)
            self.rpmCounterView.setNeedsDisplay()
            
            let avgSpeed = (x.m_wheel_speed_fr + x.m_wheel_speed_fl + x.m_wheel_speed_br + x.m_wheel_speed_bl)/4
            let fd = (x.m_wheel_speed_fr - x.m_wheel_speed_fl) * 3
            let bd = (x.m_wheel_speed_br - x.m_wheel_speed_bl) * 3
            let md = ((x.m_wheel_speed_fr + x.m_wheel_speed_fl) / 2 + (x.m_wheel_speed_br + x.m_wheel_speed_bl) / 2) * 0.25
            self.tyreStatusView.differentials = [fd, bd, md, ]
            self.tyreStatusView.suspPosition = [x.m_wheel_speed_fr - avgSpeed,
                                                x.m_wheel_speed_fl - avgSpeed,
                                                x.m_wheel_speed_br - avgSpeed,
                                                x.m_wheel_speed_bl - avgSpeed, ]
            self.tyreStatusView.suspPositionMax = 2
            
            self.tyreStatusView.force = TyreStatus.Force(lat: x.m_gforce_lat * 20, lon: x.m_gforce_lon * 5)
            self.tyreStatusView.setNeedsDisplay()
            
            self.progressGauge.progress = x.m_lapDistance / x.m_trackSize;
            self.progressGauge.setNeedsDisplay()
            
        }
    }
}
