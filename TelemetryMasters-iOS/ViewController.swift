//
//  ViewController.swift
//  TelemetryMasters
//
//  Created by shdwprince on 9/23/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import Foundation
import UIKit

class Settings {
    class F1 {
        enum Keys: String {
            case showRevCounter = "showRevCounter"
            case revCounterType = "revCounterType"
        }

        static func showRevCounter() -> Bool {
            return UserDefaults.standard.object(forKey: Keys.showRevCounter.rawValue) as? Bool ?? true
        }

        static func revCounterType() -> RevCounterView.CounterType {
            return RevCounterView.CounterType(rawValue: UserDefaults.standard.object(forKey: Keys.revCounterType.rawValue) as? Int ?? 0)!
        }
    }

    class DirtRally {
        enum Keys: String {
            case numberOfSectors = "numberOfSectors"
        }
        
        static func numberOfSectors() -> Int {
            return UserDefaults.standard.object(forKey: Keys.numberOfSectors.rawValue) as? Int ?? 10
        }
    }
}

class ViewController: UITableViewController, TelemetryDelegate {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var f1RevSwitch: UISwitch!
    @IBOutlet weak var f1RevType: UISegmentedControl!
    @IBOutlet weak var rallySectionsSlider: UISlider!
    @IBOutlet weak var rallySectionsLabel: UILabel!

    var telemetry: Telemetry?

    override func viewDidLoad() {
        telemetry = Telemetry(port: 20777)
        //telemetry = Telemetry(port: 5606)
        telemetry?.addDelegate(self)
        telemetry?.startServer()

        self.f1RevSwitch.isOn = Settings.F1.showRevCounter()
        self.f1RevType.selectedSegmentIndex = Settings.F1.revCounterType().rawValue

        self.rallySectionsSlider.value = Float(Settings.DirtRally.numberOfSectors())
        self.rallySectionsLabel.text = "\(Settings.DirtRally.numberOfSectors())"

        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
    }

    @IBAction func changedSettingsAction(_ sender: AnyObject) {
        UserDefaults.standard.set(self.f1RevSwitch.isOn, forKey: Settings.F1.Keys.showRevCounter.rawValue)
        UserDefaults.standard.set(Int(self.rallySectionsSlider.value), forKey: Settings.DirtRally.Keys.numberOfSectors.rawValue)
        UserDefaults.standard.set(self.f1RevType.selectedSegmentIndex, forKey: Settings.F1.Keys.revCounterType.rawValue)

        self.rallySectionsSlider.value = Float(Settings.DirtRally.numberOfSectors())
        self.rallySectionsLabel.text = "\(Settings.DirtRally.numberOfSectors())"
    }

    func telemetryDidProceedTo(_ stage: Telemetry.Stage, instance: Telemetry) {
        OperationQueue.main.addOperation {
            switch stage {
            case .WaitingForGame:
                self.messageLabel.text = "Waiting for the game..."
                break
            case .Connected:
                switch instance.game {
                case .F12016:
                    self.performSegue(withIdentifier: "proceedToF1Controller", sender: nil)
                case .DirtRally:
                    self.performSegue(withIdentifier: "proceedToDirtRallyController", sender: nil)
                case .PCars:
                    self.performSegue(withIdentifier: "proceedToPCarsController", sender: nil)
                default:
                    self.messageLabel.text = "Error: invalid stage"
                }
            default:
                self.messageLabel.text = "Error: invalid stage"
                break
            }
        }
    }

    func telemetryDidEncounterError(_ error: NSError, instance: Telemetry) {
        let ctrl = UIAlertController.init(title: "Error", message: nil, preferredStyle: .actionSheet)
        let errorType = Telemetry.Error(error.code)

        switch errorType {
        case Telemetry.Error.UnknownGame:
            ctrl.message = "Game not detected! Select the game:"
            ctrl.addAction(UIAlertAction.init(title: "F1 2016", style: .default, handler: { (a) in
                self.telemetry?.forceConnected(game: .F12016)
            }))

            ctrl.addAction(UIAlertAction.init(title: "Dirt Rally", style: .default, handler: { (a) in
                self.telemetry?.forceConnected(game: .DirtRally)
            }))

            ctrl.addAction(UIAlertAction.init(title: "PCars", style: .default, handler: { (a) in
                self.telemetry?.forceConnected(game: .PCars)
            }))

            break
        default:
            ctrl.message = "Unknown error has occured (\(errorType))"
            break
        }

        ctrl.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (a) in
            ctrl.dismiss(animated: true, completion: nil)
        }))

        self.present(ctrl, animated: true, completion: nil)
    }

    func telemetryDidGetPacket(_ packet: Any, instance: Telemetry) {

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "proceedToInstructions" {
            let path = Bundle.main.path(forResource: "Instructions", ofType: "html")
            let url = URL(fileURLWithPath: path!)
            let code = try! String.init(contentsOf: url)

            if let webView = segue.destination.view.viewWithTag(1) as? UIWebView {
                webView.loadHTMLString(code.replacingOccurrences(of: "{IP}", with: getHostAddress()), baseURL: nil)
            }

            self.navigationController?.isNavigationBarHidden = false
        } else {
            let controller = segue.destination as! TelemetryDelegate
            telemetry?.addDelegate(controller)
        }
    }
}

class TelemetryViewerController: UIViewController, TelemetryDelegate {
    override var prefersStatusBarHidden: Bool {
        return UIDevice.current.userInterfaceIdiom != .pad
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private var lastUpdate: CFAbsoluteTime = 0, updateInterval = 0.016

    func telemetryDidEncounterError(_ error: NSError, instance: Telemetry) {
        let ctrl = UIAlertController.init(title: "Error", message:  "Unknown error has occured (\(Telemetry.Error(error.code)))", preferredStyle: .alert)
        ctrl.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (a) in
            ctrl.dismiss(animated: true, completion: nil)
        }))

        self.present(ctrl, animated: true, completion: nil)
    }

    func telemetryDidGetPacket(_ packet: Any, instance: Telemetry) {

    }

    func telemetryDidProceedTo(_ stage: Telemetry.Stage, instance: Telemetry) {
        if stage != .Connected {
            OperationQueue.main.addOperation {
                instance.removeDelegate(self)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func formatTime(_ value: Float) -> String {
        let minutes = value / 60.0
        let seconds = value - floor(minutes) * 60.0
        let ms = (value - floor(minutes) * 60.0 - floor(seconds))

        return String.init(format: "%02d:%02d.%03d", Int(minutes), Int(seconds), Int(ms * 1000))
    }


    func queueUiUpdate(_ block: @escaping () -> Swift.Void) {
        guard CFAbsoluteTimeGetCurrent() - self.lastUpdate > self.updateInterval else {
            return
        }

        OperationQueue.main.addOperation {
            block()
            self.lastUpdate = CFAbsoluteTimeGetCurrent()
        }
    }
}

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return .landscape
    }
}
