//
//  ViewController.swift
//  TelemetryMasters-iOS
//
//  Created by shdwprince on 9/22/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import UIKit

class F12016ViewController: UIViewController, TelemetryDelegate {
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

    override var prefersStatusBarHidden: Bool {
        return UIDevice.current.userInterfaceIdiom != .pad
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    @IBOutlet weak var revCounterView: RevCounterView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var gearLabel: UILabel!

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!

    @IBOutlet weak var tyreStatusView: TyreStatus!
    @IBOutlet weak var fuelGauge: PlainGauge!
    @IBOutlet weak var fuelLabel: UILabel!
    
    private var lastUpdate: CFAbsoluteTime = 0
    private var updateInterval: CFTimeInterval = 0.016
    private var fuelMax: Float = 0
    private var currentMode: SessionType = .Unknown
    private var pitStatus: Float = -1
    private var lastLapTimes: [Float: Float] = [:]
    private var currentLapTimes: [Float: Float] = [:]
    private var lastLapTime: Float = 0

    func telemetryDidProceedTo(_ stage: Telemetry.Stage, instance: Telemetry) {
        if stage != .Connected {
            self.dismiss(animated: true, completion: {
                instance.removeDelegate(self)
            })
        }
    }

    func telemetryDidGetPacket(_ packet: Any, instance: Telemetry) {
        let x = packet as! F1UDPPacket

        if x.m_lapTime < self.lastLapTime {
            var overwrite = false
            if SessionType(x.m_sessionType) == .Race {
                overwrite = true
            } else if self.lastLapTimes.keys.max() ?? 0 > self.currentLapTimes.keys.max() ?? 0 {
                overwrite = true
            }
            
            if overwrite {
                self.lastLapTimes = self.currentLapTimes
            }
            
            self.currentLapTimes = [:]
        }
        
        self.lastLapTime = x.m_lapTime
        
        let distIdentifier = floor(x.m_lapDistance / 10)
        if !self.currentLapTimes.keys.contains(distIdentifier) {
            self.currentLapTimes[distIdentifier] = x.m_lapTime
        }
        
        OperationQueue.main.addOperation {
            guard self.revCounterView != nil else {
                return
            }
            
            guard CFAbsoluteTimeGetCurrent() - self.lastUpdate > self.updateInterval else {
                return
            }
            
            if self.fuelMax < x.m_fuel_in_tank {
                self.fuelMax = x.m_fuel_in_tank
            }
            
            if self.currentMode != SessionType(x.m_sessionType) || self.pitStatus != x.m_in_pits {
                self.currentMode = SessionType(x.m_sessionType)
                self.pitStatus = x.m_in_pits
                
                self.resetMode(new: self.currentMode)
            }
            
            self.renderRevInMode(SessionType(x.m_sessionType), packet: x)
            self.renderGaugesInMode(SessionType(x.m_sessionType), packet: x)
            self.renderLabelsInMode(SessionType(x.m_sessionType), packet: x)
            
            self.lastUpdate = CFAbsoluteTimeGetCurrent()
        }
    }

    func resetMode(new mode: SessionType) {
        self.fuelMax = 0
        self.currentLapTimes = []
        self.lastLapTimes = []
        self.lastLapTime = 0
    }

    func renderRevInMode(_ mode: SessionType, packet x: F1UDPPacket) {
        let width: Float = 0.15, offset: Float = -0.25
        let head = x.m_max_rpm + x.m_max_rpm * offset
        let window = x.m_max_rpm * width
        let progress = (x.m_engineRate - head) / window
        
        self.revCounterView.progress = progress
        self.revCounterView.setNeedsDisplay()
    }

    func renderGaugesInMode(_ mode: SessionType, packet x: F1UDPPacket) {
        self.tyreStatusView.force = TyreStatus.Force(lat: x.m_gforce_lat * 10, lon: x.m_gforce_lon * 5)
        self.tyreStatusView.suspPosition = [x.m_susp_pos_fl * 2, x.m_susp_pos_fr * 2, x.m_susp_pos_bl * 2, x.m_susp_pos_br * 2, ]
        self.tyreStatusView.suspPositionMax = 15*2
        self.tyreStatusView.setNeedsDisplay()
        
        self.fuelGauge.progress = x.m_fuel_in_tank / x.m_fuel_capacity
        self.fuelGauge.setNeedsDisplay()
    }

    func renderLabelsInMode(_ mode: SessionType, packet x: F1UDPPacket) {
        switch Int(x.m_gear) {
        case 0:
            self.gearLabel.text = "R"
        case 1:
            self.gearLabel.text = "N"
        default:
            self.gearLabel.text = "\(Int(x.m_gear - 1))"
        }

        let speedCoef: Double = 3.6
        self.speedLabel.text = "\(Int(Double(x.m_speed) * speedCoef))"

        if (mode == .Race) {
            self.positionLabel.text = "P\(Int(x.m_car_position)) L\(Int(x.m_lap))"
        } else {
            self.positionLabel.text = "P\(Int(x.m_car_position)) L\(Int(x.m_lap))"
        }

        self.fuelLabel.text = String(format:"%.0flb", x.m_fuel_in_tank)
        self.mainLabel.text = self.formatTime(x.m_lapTime)

        let distIdentifier = floor(x.m_lapDistance / 10)
        if let last = lastLapTimes[distIdentifier],
           let current = currentLapTimes[distIdentifier] {
            let delta = current - last
            self.secondaryLabel.text = String.init(format: "%02.3f", delta)
            self.secondaryLabel.textColor = delta <= 0 ? UIColor.green : UIColor.red
        } else {
            self.secondaryLabel.text = "---"
            self.secondaryLabel.textColor = UIColor.white
        }
        
    }

    func formatTime(_ value: Float) -> String {
        let minutes = value / 60.0
        let seconds = value - floor(minutes) * 60.0
        let ms = (value - floor(minutes) * 60.0 - floor(seconds))

        return String.init(format: "%02d:%02d.%03d", Int(minutes), Int(seconds), Int(ms * 1000))
    }

    override func viewDidLoad() {
        let height = UIScreen.main.bounds.size.height

        if height <= 480 {
            self.speedLabel.font = self.speedLabel.font.withSize(72)
            self.secondaryLabel.font = self.secondaryLabel.font.withSize(48)
            self.mainLabel.font = self.mainLabel.font.withSize(28)
        } else if height <= 568 {
            self.speedLabel.font = self.speedLabel.font.withSize(96)
            self.secondaryLabel.font = self.secondaryLabel.font.withSize(72)
            self.mainLabel.font = self.mainLabel.font.withSize(48)
        }

        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

