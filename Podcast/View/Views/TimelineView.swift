//
//  TimelineView.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Philip Dukhov on 9/17/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import UIKit

class TimelineView: UIView {
    struct Props {
        let stringsAndFrames: [String: CGRect]
        let gridFrames: [CGRect]
    }
    
    private var visibleTextLayers = [String:CATextLayer]()
    private var cachedTextLayers = [CATextLayer]()
    
    private var visibleGridLayers = [CALayer]()
    private var cachedGridLayers = [CALayer]()
    
    var visibleRange: ClosedRange<TimeInterval>! {
        didSet {
            let duration = visibleRange.upperBound - visibleRange.lowerBound
            var step = (duration / 7).rounded(.up)
            let stepLog10 = log10(step).rounded()
            if stepLog10 > 1 {
                step = (step / pow(10, stepLog10 - 1)).rounded(.up) * pow(10, stepLog10 - 1)
            }
            
            let values = stride(
                from: visibleRange.lowerBound,
                to: visibleRange.upperBound,
                by: step
            )
            let stringsAndFrames = values.reduce(into: [String: CGRect]()) {
                $0[$1.timeString] = CGRect(
                    x: CGFloat(($1 - visibleRange.lowerBound) / duration) * bounds.width - 13,
                    y: 5,
                    width: 26,
                    height: 12)
            }
            let gridFrames = stride(
                from: visibleRange.lowerBound,
                to: visibleRange.upperBound,
                by: step / 8
            ).map { value -> CGRect in
                let height: CGFloat
                switch modf((value - visibleRange.lowerBound) / step).1 {
                case 0:
                    height = 1 * 8
                    
                case 0.5:
                    height = 0.75 * 8
                    
                case 0.25, 0.75:
                    height = 0.5 * 8
                    
                default:
                    height = 0.25 * 8
                }
                return CGRect(
                    x: CGFloat((value - visibleRange.lowerBound) / duration) * bounds.width,
                    y: bounds.height - height,
                    width: 1,
                    height: height)
            }
            
            props = Props(stringsAndFrames:
                stringsAndFrames, gridFrames: gridFrames)
        }
    }
     
    
    private var props: Props? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var newDateLayers = [String:CATextLayer]()
        var newGreedLayers = [CALayer]()
        defer {
            (visibleGridLayers + Array(visibleTextLayers.values)).forEach { $0.removeFromSuperlayer() }
            cachedTextLayers += visibleTextLayers.values
            cachedGridLayers += visibleGridLayers
            visibleTextLayers = newDateLayers
            visibleGridLayers = newGreedLayers
        }
        guard let props = props else { return }
        for (string, frame) in props.stringsAndFrames where frame.minX >= 0 && frame.maxX <= bounds.width {
            let dateLayer = visibleTextLayers.removeValue(forKey: string) ?? deqeueTextLayer()
            dateLayer.string = string
            dateLayer.frame = frame
            newDateLayers[string] = dateLayer
        }
        
        newGreedLayers = props.gridFrames.compactMap { frame -> CALayer? in
            let layer = visibleGridLayers.popLast() ?? deqeueGreedLayer()
            layer.frame = frame
            return layer
        }
    }
    
    private func deqeueTextLayer() -> CATextLayer {
        let result: CATextLayer
        if cachedTextLayers.count > 0 {
            result = cachedTextLayers.popLast()!
        }
        else {
            result = CATextLayer()
            result.contentsScale = UIScreen.main.scale
            result.alignmentMode = .center
            result.foregroundColor = Asset.Colors.timelineGray.color.cgColor
            result.setUIFont(UIFont.systemFont(ofSize: 9))
            result.actions = disabledActions
        }
        layer.addSublayer(result)
        return result
    }
    
    private func deqeueGreedLayer() -> CALayer {
        let result: CALayer
        if cachedGridLayers.count > 0 {
            result = cachedGridLayers.popLast()!
        }
        else {
            result = CALayer()
            result.backgroundColor = Asset.Colors.timelineGray.color.cgColor
            result.actions = disabledActions
        }
        layer.addSublayer(result)
        return result
    }
}



extension CATextLayer {
    func setUIFont(_ uifont: UIFont?) {
        if let uifont = uifont {
            font = uifont.fontName as CFTypeRef
            fontSize = uifont.pointSize
        }
        else {
            font = nil
        }
    }
}


fileprivate let disabledActions = [
    "position": NSNull(),
    "contents": NSNull(),
    "bounds": NSNull(),
    "foregroundColor": NSNull()
]
