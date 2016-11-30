//
//  CustomViews.swift
//  TelemetryMasters
//
//  Created by shdwprince on 9/22/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

@IBDesignable
class RevCounterView: UIView {
    enum DRSState {
        case disabled
        case available
        case enabled
    }

    enum CounterType: Int {
        case full = 0
        case limited
    }
    
    enum Light: Int {
        case drs = 0
        case firstRev = 5
        case middleRev = 9
        case lastRev = 14
    }

    @IBInspectable var count: Int = 15
    @IBInspectable var border: CGFloat = 12, radius: CGFloat = 0
    var type = CounterType.limited

    let colors = [UIColor.black,
                  UIColor(red: 0.2, green: 1.0, blue: 0.2, alpha: 1.0),
                  UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0),
                  UIColor(red: 0.33, green: 0.0, blue: 1.0, alpha: 1.0), ]
    let overlayColors = [UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3).cgColor,
                         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.01).cgColor, ]

    var layers: [CALayer] = []
    var overlays: [CAGradientLayer] = []

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.sublayers?.removeAll()

        layers = []
        overlays = []
        radius = (self.frame.width - border*CGFloat(count)) / CGFloat(count) / 2
        for i in 0..<count {
            let point = CGPoint(x: border/2 + CGFloat(i)*(radius*2 + border), y: 0)

            let layer = CALayer()
            layer.frame = CGRect(x: point.x, y: point.y, width: radius*2, height: radius*2)
            layer.cornerRadius = radius

            let overlayLayer = CAGradientLayer()
            overlayLayer.frame = layer.frame
            overlayLayer.cornerRadius = layer.cornerRadius

            overlayLayer.startPoint = CGPoint(x: 1, y: 0)
            overlayLayer.endPoint = CGPoint(x: 0.8, y: 1)

            if self.frame.size.height > 0 {
                self.layer.addSublayer(layer)
                self.layer.addSublayer(overlayLayer)
            }

            layers.append(layer)
            overlays.append(overlayLayer)

            self.setLight(at: i, false)
        }
    }

    func index(of light: Light) -> Int {
        switch light {
        case .drs:
            return self.type == .limited ? 0 : 4
        case .firstRev:
            return self.type == .limited ? 5 : 0
        case .middleRev:
            return self.type == .limited ? 9 : 5
        case .lastRev:
            return 14
        }
    }

    var lightsAnimationTime: [Int: CFAbsoluteTime] = [:]
    func blinkLight(at index: Int, interval: Double) {
        let layer = self.layers[index]

        if layer.animationKeys()?.count ?? 0 == 0 {
            
            let anim = CABasicAnimation(keyPath: "backgroundColor")
            anim.toValue = self.colors[0].cgColor
            anim.duration = interval
            anim.isRemovedOnCompletion = true
            
            layer.add(anim, forKey: "blinkAnimation")
        }
    }

    func blinkLight(at index: Light, interval: Double) {
        self.blinkLight(at: self.index(of: index), interval: interval)
    }

    func blinkLights(from: Light, to: Light, interval: Double) {
        for index in self.index(of: from) ... self.index(of: to) {
            self.blinkLight(at: index, interval: interval)
        }
    }

    func setLight(at index: Light, _ state: Bool) {
        self.setLight(at: self.index(of: index), state)
    }

    func setLight(at index: Int, _ state: Bool) {
        // check whether there is animation running right now
        guard self.layers[index].animationKeys()?.count ?? 0 == 0 else {
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let layer = self.layers[index]
        let overlay = self.overlays[index]

        if state {
            overlay.colors = self.overlayColors.reversed()

            if index < self.count / 3 {
                layer.backgroundColor = self.colors[1].cgColor
            } else if index < self.count - self.count / 3 {
                layer.backgroundColor = self.colors[2].cgColor
            } else {
                layer.backgroundColor = self.colors[3].cgColor
            }
            
        } else {
            layer.backgroundColor = self.colors[0].cgColor
            overlay.colors = self.overlayColors
        }

        CATransaction.commit()
    }

    func setRevLight(progress: Float, drsLight: Bool) {
        let range = (self.index(of: .firstRev) ... self.index(of: .lastRev))
        for (relativeIndex, i) in range.enumerated() {
            if drsLight && self.index(of: .drs) == i {
                continue 
            }
            
            self.setLight(at: i, Float(relativeIndex) <= progress * Float(range.count))
        }
    }

    #if TARGET_INTERFACE_BUILDER
    override func draw(_ rect: CGRect) {
        self.layoutSubviews()
        self.setRevLight(progress: 0.7)
    }
    #endif
}

@IBDesignable
class RallyRPMCounter: UIView {
    var background = CAShapeLayer(), foreground = CAGradientLayer()
    var overlay = CAReplicatorLayer()
    var progressPath = UIBezierPath()
    var foregroundMask = CAShapeLayer()

    @IBInspectable var separators: Bool = true
    @IBInspectable var progress: CGFloat = 0.5
    @IBInspectable var lineHeight: CGFloat = 30
    @IBInspectable var counterBackgroundColor: UIColor = UIColor.darkGray
    @IBInspectable var startColor: UIColor = UIColor.green
    @IBInspectable var middleColor: UIColor = UIColor.yellow
    @IBInspectable var endColor: UIColor = UIColor.red

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.sublayers?.removeAll()

        let f = self.frame
        progressPath = UIBezierPath()

        progressPath.move(to: CGPoint(x: 0, y: f.height))
        progressPath.addQuadCurve(to: CGPoint(x: f.width, y: f.height), controlPoint: CGPoint(x: f.width/2, y: lineHeight))
        progressPath.addLine(to: CGPoint(x: f.width, y: f.height - lineHeight))
        progressPath.addQuadCurve(to: CGPoint(x: 0, y: f.height - lineHeight), controlPoint: CGPoint(x: f.width/2, y: 0))

        // background
        background = CAShapeLayer()
        background.path = progressPath.cgPath
        background.fillColor = counterBackgroundColor.cgColor
        self.layer.addSublayer(background)

        // foreground
        foreground = CAGradientLayer()
        foregroundMask = CAShapeLayer()
        foregroundMask.path = progressPath.cgPath
        foregroundMask.frame = CGRect(x: 0, y: 0, width: f.width*progress, height: f.height)
        foregroundMask.masksToBounds = true

        foreground.frame = CGRect(x: 0, y: 0, width: f.width, height: f.height)
        foreground.mask = foregroundMask
        foreground.backgroundColor = UIColor.darkGray.cgColor
        
        foreground.colors = [startColor.cgColor, middleColor.cgColor, endColor.cgColor, ]
        foreground.startPoint = CGPoint(x: 0.5, y: 0)
        foreground.endPoint = CGPoint(x: 0.9, y: 0)
        self.layer.addSublayer(foreground)

        // overlay
        let overlayShapeWidth: CGFloat = 10, overlayShapeBorder: CGFloat = 50
        overlay.instanceCount = Int(f.width / overlayShapeBorder) + 1
        overlay.instanceTransform = CATransform3DMakeTranslation(overlayShapeBorder, 0, 0)
        let overlayShape = CALayer()
        overlayShape.frame = CGRect(x: overlayShapeWidth, y: 0, width: overlayShapeWidth, height: f.height)
        overlayShape.backgroundColor = UIColor.black.cgColor
        overlay.frame = CGRect(x: 0, y: 0, width: f.width, height: f.height)

        let overlayMask = CAShapeLayer()
        overlayMask.path = progressPath.cgPath
        overlay.mask = overlayMask

        overlay.masksToBounds = true
        overlay.addSublayer(overlayShape)

        if separators {
            self.layer.addSublayer(overlay)
        }
    }

    override func setNeedsDisplay() {
        foregroundMask.frame = CGRect(x: 0, y: 0, width: self.frame.width*progress, height: self.frame.height)
        super.setNeedsDisplay()
    }
    
    #if TARGET_INTERFACE_BUILDER
    override func draw(_ rect: CGRect) {
        self.layoutSubviews()
        self.setNeedsDisplay()
    }
    #endif
}

@IBDesignable
class PlainGauge: UIView {
    @IBInspectable var progress: Float = 0
    @IBInspectable var horizontal: Bool = false
    @IBInspectable var colored: Bool = false
    @IBInspectable var delimeters: Bool = false
    @IBInspectable var delimetersCount: Int = 10
    let gaugeLayer = CALayer()
    let delimetersLayer = CAShapeLayer()

    override func layoutSubviews() {
        self.layer.sublayers?.removeAll()
        self.layer.addSublayer(gaugeLayer)

        if delimeters {
            let path = UIBezierPath()
            for i in 0...delimetersCount {
                path.move(to: CGPoint(x: CGFloat(i) * self.frame.width / 10, y: 0))
                path.addLine(to: CGPoint(x: CGFloat(i) * self.frame.width / 10, y: self.frame.height))
            }
            
            delimetersLayer.path = path.cgPath
            delimetersLayer.strokeColor = UIColor.black.cgColor
            self.layer.addSublayer(delimetersLayer)
        }

        super.layoutSubviews()
    }

    override func setNeedsDisplay() {
        let rect = self.frame

        gaugeLayer.frame = CGRect(x: 0, y: 0, width: rect.width * CGFloat(self.progress), height: self.frame.height)
        if horizontal {
            gaugeLayer.frame = CGRect(x: 0, y: 0, width: rect.width * CGFloat(self.progress), height: rect.height)
        } else {
            let offset = rect.height - rect.height * CGFloat(self.progress)
            gaugeLayer.frame = CGRect(x: 0, y: offset, width: rect.width, height: rect.height - offset)
        }

        if colored {
            gaugeLayer.backgroundColor = UIColor(red: CGFloat(1.0 * (1.0-progress)), green: CGFloat(1.0 * progress), blue: 0, alpha: 1).cgColor
        } else {
            gaugeLayer.backgroundColor = UIColor.white.cgColor
        }

        super.setNeedsDisplay()
    }

    #if TARGET_INTERFACE_BUILDER
    override func draw(_ rect: CGRect) {
        self.layoutSubviews()
        self.setNeedsDisplay()
    }
    #endif
}

@IBDesignable
class TyreStatus: UIView {
    struct Force {
        let lat, lon: Float
    }

    var suspPosition: [Float] = [10.0, 7.0, 7.0, 5.0, ]
    var differentials: [Float] = [10.0, 7.0, 7, ]
    @IBInspectable var suspPositionMax: Float = 13.0
    @IBInspectable var force: Force = Force(lat: -15, lon: -1)

    @IBInspectable var xOffset: CGFloat = 40
    @IBInspectable var yOffset: CGFloat = 40
    @IBInspectable var forceOffset: CGFloat = 20
    @IBInspectable var forceHeight: CGFloat = 20
    @IBInspectable var bouncerRadius: CGFloat = 20

    @IBInspectable var diffEnabled: Bool = true
    @IBInspectable var diffWidth: CGFloat = 3
    @IBInspectable var diffHeight: CGFloat = 9

    var tireLayers = [CALayer(), CALayer(), CALayer(), CALayer(), ]
    var bouncerLayer = CALayer()
    var diffLayers = [CALayer(), CALayer(), CALayer(), ]

    override func layoutSubviews() {
        self.layer.sublayers?.removeAll()

        let tireWidth = self.frame.width / 6
        let tireHeight = self.frame.height / 4

        let outline = UIBezierPath()
        outline.move(to: CGPoint(x: xOffset + tireWidth, y: self.frame.height / 4))
        outline.addLine(to: CGPoint(x: self.frame.width - xOffset - tireWidth, y: self.frame.height / 4))
        
        outline.move(to: CGPoint(x: xOffset + tireWidth, y: self.frame.height - self.frame.height / 4))
        outline.addLine(to: CGPoint(x: self.frame.width - xOffset - tireWidth, y: self.frame.height - self.frame.height / 4))

        outline.move(to: CGPoint(x: self.frame.width / 2, y: self.frame.height / 4))
        outline.addLine(to: CGPoint(x: self.frame.width / 2, y: self.frame.height - self.frame.height / 4))

        for (i, rect) in [CGRect(x: xOffset, y: yOffset, width: tireWidth, height: tireHeight),
                          CGRect(x: self.frame.width - xOffset - tireWidth, y: yOffset, width: tireWidth, height: tireHeight),
                          CGRect(x: xOffset, y: self.frame.height - yOffset - tireHeight, width: tireWidth, height: tireHeight),
                          CGRect(x: self.frame.width - xOffset - tireWidth, y: self.frame.height - yOffset - tireHeight, width: tireWidth, height: tireHeight), ].enumerated()
        {
            let layer = tireLayers[i]
            layer.frame = rect
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = 1.0
            layer.cornerRadius = 3.0
            
            self.layer.addSublayer(layer)
        }

        let outlineLayer = CAShapeLayer()
        outlineLayer.path = outline.cgPath
        outlineLayer.strokeColor = UIColor.white.cgColor
        outlineLayer.shouldRasterize = true
        self.layer.addSublayer(outlineLayer)

        let forceOutlineLayer = CAShapeLayer()
        forceOutlineLayer.path = UIBezierPath(roundedRect: CGRect(x: xOffset, y: forceOffset, width: self.frame.width - xOffset * 2, height: forceHeight), cornerRadius: 3).cgPath
        forceOutlineLayer.strokeColor = UIColor.white.cgColor
        forceOutlineLayer.shouldRasterize = true
        self.layer.addSublayer(forceOutlineLayer)

        bouncerLayer = CALayer()
        bouncerLayer.backgroundColor = UIColor.white.cgColor
        bouncerLayer.cornerRadius = bouncerRadius
        bouncerLayer.frame = CGRect(x: self.frame.width / 2 - bouncerRadius,
                                    y: forceOffset - bouncerRadius + forceHeight / 2 + CGFloat(force.lon),
                                    width: bouncerRadius * 2,
                                    height: bouncerRadius * 2)
        self.layer.addSublayer(bouncerLayer)

        if diffEnabled {
            for l in diffLayers {
                l.backgroundColor = UIColor.white.cgColor
                self.layer.addSublayer(l)
            }
        }

        super.layoutSubviews()
    }

    override func setNeedsDisplay() {
        for (i, layer) in tireLayers.enumerated() {
            let power: Float = self.suspPosition[i] / self.suspPositionMax
            var red: Float = 0.0, green: Float = 1.0
            if power <= 0 {
            } else if power<0.5 {
                green = 1.0
                red = 2 * power
            } else if power<=1 {
                red = 1.0
                green = 1.0 - 2.0 * (power-0.5)
            } else {
                red = 1.0
            }

            layer.backgroundColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: 0, alpha: 1).cgColor
        }

        bouncerLayer.frame = CGRect(x: self.frame.width / 2 + CGFloat(force.lat) - bouncerRadius,
                                    y: forceOffset - bouncerRadius + forceHeight / 2 + CGFloat(force.lon),
                                    width: bouncerRadius * 2,
                                    height: bouncerRadius * 2)

        if diffEnabled {
            var diffStatus = self.differentials[0]
            let offset = self.frame.width / 2
            diffLayers[0].frame = CGRect(x: offset + CGFloat(diffStatus) - diffWidth/2, y: self.frame.height / 4 - diffHeight/2, width: diffWidth, height: diffHeight)

            diffStatus = self.differentials[1]
            diffLayers[1].frame = CGRect(x: self.frame.width - offset + CGFloat(diffStatus) - diffWidth/2, y: self.frame.height - self.frame.height / 4 - diffHeight/2, width: diffWidth, height: diffHeight)

            diffStatus = self.differentials[2]
            diffLayers[2].frame = CGRect(x: self.frame.width / 2 - diffHeight/2, y: self.frame.height / 2 + CGFloat(diffStatus) - diffWidth/2, width: diffHeight, height: diffWidth)
        }

        super.setNeedsDisplay()
    }

    #if TARGET_INTERFACE_BUILDER
    override func draw(_ rect: CGRect) {
        self.layoutSubviews()
        self.setNeedsDisplay()
    }
    #endif
}

@IBDesignable
class DigitizedTextView: UIView {
    var textLayer = CATextLayer(), backgroundLayer = CATextLayer()
    @IBInspectable var text: String = ""

    override func layoutSubviews() {
        self.layer.sublayers?.removeAll()

        backgroundLayer.foregroundColor = UIColor.black.cgColor
        textLayer.foregroundColor = UIColor.red.cgColor

        let fontName: CFString = "Menlo" as CFString
        textLayer.font = CTFontCreateWithName(fontName, 13.0, nil)
        textLayer.alignmentMode = kCAAlignmentLeft
        textLayer.contentsScale = UIScreen.main.scale
        backgroundLayer.font = CTFontCreateWithName(fontName, 13.0, nil)

        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(textLayer)
        super.layoutSubviews()
    }

    override func setNeedsDisplay() {
        textLayer.string = text
        
        var backgroundString = ""
        for _ in 0...text.characters.count {
            backgroundString.append("0")
        }

        backgroundLayer.string = backgroundString
    }

    #if TARGET_INTERFACE_BUILDER
    override func draw(_ rect: CGRect) {
        self.layoutSubviews()
        self.setNeedsDisplay()
    }
    #endif
}
