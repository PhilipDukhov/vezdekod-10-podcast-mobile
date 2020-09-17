//
//  WaveformView.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Philip Dukhov on 9/17/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import UIKit

class WaveformView: UIView {
    override class var layerClass: AnyClass { CAShapeLayer.self }
    override var layer: CAShapeLayer { super.layer as! CAShapeLayer }
    
    var samples: [CGFloat] = [] {
        didSet {
            guard samples != oldValue else { return }
            setNeedsUpdatePath()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.fillColor = Asset.Colors.blue.color.cgColor
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
            layer.path = nil
            return
        }
        
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = layer.path == nil ? path(minified: true) : layer.path
        layer.path = path(minified: false)
        pathAnimation.toValue = layer.path
        pathAnimation.duration = 0.3
        pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        layer.add(pathAnimation, forKey: "pathAnimation")
    }
    
    private func path(minified: Bool) -> CGPath {
        let path = CGMutablePath()
        let xMultiplier = 1 / max(1, CGFloat(samples.count - 1))
        let width: CGFloat = 2
        samples.enumerated()
            .compactMap { x, sample -> CGRect? in
                let height = sample * (bounds.height) / 3
                let width = height >= width * 2 ? width : height / 2
                return CGRect(
                    x: CGFloat(x) * xMultiplier * (bounds.width - width),
                    y: (bounds.height - height) / 2,
                    width: width, height: height
                )
        } .forEach {
            var rect = $0
            if minified {
                var newRect = rect
                newRect.size.width /= 10
                newRect.size.height /= 10
                newRect.origin.x = rect.midX - newRect.size.width / 2
                newRect.origin.y = rect.midY - newRect.size.height / 2
                rect = newRect
            }
            let corner = min(rect.width, rect.height) / 2
            path.addRoundedRect(in: rect, cornerWidth: corner, cornerHeight: corner)
        }
        return path
    }
    
    private var needUpdatePath = false
    private var previousSize: CGSize? {
        didSet {
            guard oldValue != previousSize else { return }
            setNeedsUpdatePath()
        }
    }
}
