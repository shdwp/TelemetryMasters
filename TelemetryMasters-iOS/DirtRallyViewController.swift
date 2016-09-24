//
//  DirtRallyViewController.swift
//  TelemetryMasters
//
//  Created by shdwprince on 9/23/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import Foundation
import UIKit

class DirtRallyViewController: UIViewController, TelemetryDelegate {
    override var prefersStatusBarHidden: Bool {
        return UIDevice.current.userInterfaceIdiom != .pad
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tyreStatusView: TyreStatus!
    @IBOutlet weak var rpmCounterView: RallyRPMCounter!
    @IBOutlet weak var throttleCounterView: RallyRPMCounter!
    @IBOutlet weak var gearLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var progressGauge: PlainGauge!

    private var lastUpdate: CFAbsoluteTime = 0, updateInterval = 0.016

    func telemetryDidProceedTo(_ stage: Telemetry.Stage, instance: Telemetry) {
        if stage != .Connected {
            self.dismiss(animated: true, completion: {
                instance.removeDelegate(self)
            })
        }
    }

    func telemetryDidGetPacket(_ packet: Any, instance: Telemetry) {
        let x = packet as! DirtRallyPacket

        OperationQueue.main.addOperation {
            guard CFAbsoluteTimeGetCurrent() - self.lastUpdate > self.updateInterval else {
                return
            }

            switch Int(x.m_gear) {
            case 10:
                self.gearLabel.text = "R"
            case 0:
                self.gearLabel.text = "N"
            default:
                self.gearLabel.text = "\(Int(x.m_gear))"
            }

            self.speedLabel.text = "\(Int(x.m_speed * 3.6))"
            self.timeLabel.text = self.formatTime(x.m_time)

            self.throttleCounterView.progress = CGFloat(x.m_throttle)
            self.throttleCounterView.setNeedsDisplay()

            self.rpmCounterView.progress = CGFloat(x.m_engineRate / x.m_max_rpm)
            self.rpmCounterView.setNeedsDisplay()

            let fd = x.m_wheel_speed_fr - x.m_wheel_speed_fl
            let bd = x.m_wheel_speed_br - x.m_wheel_speed_bl
            let md = (x.m_wheel_speed_fr + x.m_wheel_speed_fl) / 2 + (x.m_wheel_speed_br + x.m_wheel_speed_bl) / 2
            self.tyreStatusView.differentials = [fd, bd, md, ]
            self.tyreStatusView.suspPosition = [50+x.m_susp_pos_fl, 50+x.m_susp_pos_fr, 50+x.m_susp_pos_bl, 50+x.m_susp_pos_br, ]
            self.tyreStatusView.suspPositionMax = 50
            self.tyreStatusView.force = TyreStatus.Force(lat: x.m_gforce_lat * 20, lon: x.m_gforce_lon * 5)
            self.tyreStatusView.setNeedsDisplay()

            self.progressGauge.progress = x.m_lapDistance / x.m_trackSize;
            self.progressGauge.setNeedsDisplay()

            self.lastUpdate = CFAbsoluteTimeGetCurrent()
        }
    }

    func formatTime(_ value: Float) -> String {
        let minutes = value / 60.0
        let seconds = value - floor(minutes) * 60.0
        let ms = (value - floor(minutes) * 60.0 - floor(seconds))

        return String.init(format: "%02d:%02d.%03d", Int(minutes), Int(seconds), Int(ms * 1000))
    }
}
