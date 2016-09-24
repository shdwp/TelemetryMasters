//
//  ViewController.swift
//  TelemetryMasters
//
//  Created by shdwprince on 9/23/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, TelemetryDelegate {
    @IBOutlet weak var webView: UIWebView!

    var initialWaiting = true
    var telemetry: Telemetry?

    override func viewDidLoad() {
        telemetry = Telemetry(port: 20777)
        telemetry?.addDelegate(self)
        telemetry?.startServer()

        super.viewDidLoad()
    }

    func telemetryDidProceedTo(_ stage: Telemetry.Stage, instance: Telemetry) {
        OperationQueue.main.addOperation {
            switch stage {
            case .Unknown:
                self.webView.loadHTMLString("Error: unknown stage", baseURL: nil)
                break
            case .WaitingForGame:
                if self.initialWaiting {
                    self.initialWaiting = false

                    let path = Bundle.main.path(forResource: "Instructions", ofType: "html")
                    let url = URL(fileURLWithPath: path!)
                    let code = try! String.init(contentsOf: url)

                    self.webView.loadHTMLString(code.replacingOccurrences(of: "{IP}", with: getHostAddress()), baseURL: nil)
                } else {
                    self.webView.loadHTMLString("<h1>Waiting for the game...</h1>", baseURL: nil)
                }
                break
            case .Connected:
                switch instance.game {
                case .F12016:
                    self.performSegue(withIdentifier: "proceedToF1Controller", sender: nil)
                case .DirtRally:
                    self.performSegue(withIdentifier: "proceedToDirtRallyController", sender: nil)
                default:
                    self.webView.loadHTMLString("Error: unknown game", baseURL: nil)
                }
            }
        }
    }

    func telemetryDidGetPacket(_ packet: Any, instance: Telemetry) {

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! TelemetryDelegate
        telemetry?.addDelegate(controller)
    }
}
