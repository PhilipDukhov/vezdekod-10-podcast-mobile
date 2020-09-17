//
//  WaveformView.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Philip Dukhov on 9/17/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import UIKit

class WaveformView: UIView {
    struct Sample: Equatable {
        let sourceTime: TimeInterval
        let value: CGFloat
    }
    
    var samples: [Sample] = [] {
        didSet {
            guard samples != oldValue else { return }
            setNeedsUpdatePath()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previousSize = bounds.size
    }
    
    private func setNeedsUpdatePath() {
        guard !needUpdatePath else { return }
        needUpdatePath = true
        DispatchQueue.main.async {
            self.updatePathIfNeeded()
        }
    }
    
    private func updatePathIfNeeded() {
        guard needUpdatePath else { return }
        needUpdatePath = false
        guard !samples.isEmpty else {
            return
        }
        if layer.sublayers?.isEmpty == true {
            updateLayers(minified: true)
        }
        updateLayers(minified: false)
    }
    
    private func updateLayers(minified: Bool)  {
        var newLayers = [TimeInterval:CALayer]()
        defer {
            visibleLayers.values.forEach { $0.removeFromSuperlayer() }
            cachedLayers += visibleLayers.values
            visibleLayers = newLayers
        }
        
        let xMultiplier = 1 / max(1, CGFloat(samples.count - 1))
        let width: CGFloat = 2
        samples.enumerated()
            .forEach { x, sample in
                let height = sample.value * (bounds.height) / 3
                let width = height >= width * 2 ? width : height / 2
                var rect = CGRect(
                    x: CGFloat(x) * xMultiplier * (bounds.width - width),
                    y: (bounds.height - height) / 2,
                    width: width, height: height
                )
                if minified {
                    var newRect = rect
                    newRect.size.width /= 10
                    newRect.size.height /= 10
                    newRect.origin.x = rect.midX - newRect.size.width / 2
                    newRect.origin.y = rect.midY - newRect.size.height / 2
                    rect = newRect
                }
                let layer = visibleLayers.removeValue(forKey: sample.sourceTime) ?? deqeueLayer()
                layer.frame = rect
                layer.cornerRadius = min(rect.width, rect.height) / 2
                newLayers[sample.sourceTime] = layer
        }
    }
    
    private var needUpdatePath = false
    private var previousSize: CGSize? {
        didSet {
            guard oldValue != previousSize else { return }
            setNeedsUpdatePath()
        }
    }
    
    private var cachedLayers = [CALayer]()
    private var visibleLayers = [TimeInterval:CALayer]()
    private func deqeueLayer() -> CALayer {
        let result: CALayer
        if cachedLayers.count > 0 {
            result = cachedLayers.popLast()!
        }
        else {
            result = CALayer()
            result.backgroundColor = Asset.Colors.blue.color.cgColor
//            result.actions = disabledActions
        }
        layer.addSublayer(result)
        return result
    }
}
