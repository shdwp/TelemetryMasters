//
//  AppDelegate.swift
//  TelemetryMasters
//
//  Created by shdwprince on 9/22/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!

    var ld: Int32 = 0
    let queue = OperationQueue()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.ld = UDPSock(10577)
        if self.ld > 0 {
            queue.addOperation {
                while true {
                    var x: F1UDPPacket = F1UDPPacket.init()
                    F1UDPRead(self.ld, &x)
                    OperationQueue.main.addOperation {
                        self.render(packet: x)
                    }
                }
            };
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func render(packet: F1UDPPacket) {
        self.setLabel(id: 0, text: "Lap time: \(packet.m_lapTime)/\(packet.m_last_lap_time)")
        self.setLabel(id: 1, text: "Lap distance: \(packet.m_lapDistance)")
        self.setLabel(id: 2, text: "Total distance: \(packet.m_totalDistance)")
        self.setLabel(id: 3, text: "Track size: \(packet.m_track_size)")
        self.setLabel(id: 4, text: "KERS: \(packet.m_kers_level)/\(packet.m_kers_max_level)")
        self.setLabel(id: 5, text: "WHEELS: \(packet.m_wheels_pressure)")
        self.setLabel(id: 6, text: "GForce: \(packet.m_gforce_lat)/\(packet.m_gforce_lon)")
        self.setLabel(id: 7, text: "FUEL: \(packet.m_fuel_in_tank)/\(packet.m_fuel_capacity)")
    }

    func setLabel(id: Int, text: String) {
        let label: NSTextField = self.window.contentView?.viewWithTag(id) as! NSTextField
        label.stringValue = text
    }
}

