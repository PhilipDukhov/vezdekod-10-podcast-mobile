//
//  AudioSlider.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Philip Dukhov on 9/17/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import UIKit

class AudioSlider: UIControl {
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var trimmingView: UIView!
    @IBOutlet private var startView: UIView!
    @IBOutlet private var endView: UIView!
    @IBOutlet private var thumbView: UIView!
    @IBOutlet private var startPositionConstraint: NSLayoutConstraint!
    @IBOutlet private var endPositionConstraint: NSLayoutConstraint!
    @IBOutlet private var thumbPositionConstraint: NSLayoutConstraint!
    
    enum TrackingControl: CaseIterable {
        case start
        case end
        case thumb
    }
    
    private var _minValue: Double = 0
    private var _maxValue: Double = 1
    private var _minSelectedValue: Double = 0
    private var _maxSelectedValue: Double = 1
    private var _minSelectionRange: Double = 0.1
    
    var thumbValueChanged: ((Double) -> Void)?
    
    var minValue: Double {
        set {
            guard _minValue != newValue else { return }
            _minValue = newValue
            minSelectedValue = _minSelectedValue
            setNeedsUpdateConstraints()
        }
        get { return _minValue }
    }
    
    var maxValue: Double {
        set {
            guard _maxValue != newValue else { return }
            _maxValue = newValue
            _maxSelectedValue = newValue
            setNeedsUpdateConstraints()
        }
        get { return _maxValue }
    }
    
    func setSelectedValues(minValue: Double, maxValue: Double) {
        _minSelectedValue = max(self.minValue, minValue)
        _maxSelectedValue = min(self.maxValue, maxValue)
        setNeedsUpdateConstraints()
    }
    
    var minSelectedValue: Double {
        set {
            let newValue = max(min(newValue, maxSelectedValue - minSelectionRange), minValue)
            guard _minSelectedValue != newValue else { return }
            _minSelectedValue = newValue
            setNeedsUpdateConstraints()
        }
        get { return _minSelectedValue }
    }
    
    var maxSelectedValue: Double {
        set {
            let newValue = min(max(newValue, minSelectedValue + minSelectionRange), maxValue)
            guard _maxSelectedValue != newValue else { return }
            _maxSelectedValue = newValue
            setNeedsUpdateConstraints()
        }
        get { return _maxSelectedValue }
    }
    
    private var _thumbValue: Double = 0
    var thumbValue: Double {
        set {
            let newValue = max(min(newValue, maxValue), minValue)
            guard _thumbValue != newValue else { return }
            _thumbValue = newValue
            setNeedsUpdateConstraints()
        }
        get { _thumbValue }
    }
    
    var minSelectionRange: Double {
        set {
            let newValue = max(newValue, 0)
            guard _minSelectionRange != newValue else { return }
            _minSelectionRange = newValue
            setNeedsUpdateConstraints()
        }
        get { return _minSelectionRange }
    }
    
    var trimmingViewVisible = false {
        didSet {
            UIView.animate(withDuration: 0.3, animations: {
                self.trimmingView.alpha = self.trimmingViewVisible ? 1 : 0
            }) { finished in
                if finished, !self.trimmingViewVisible {
                    self.minSelectedValue = 0
                    self.maxSelectedValue = self.maxValue
                }
            }
            sendActions(for: .valueChanged)
        }
    }
    
    private var minPosition: CGFloat { 0 }
    private var maxPosition: CGFloat { backgroundView.frame.width }
    private var trackingControl = [UITouch:TrackingControl]()
    private var initialPoint = [UITouch:CGPoint]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isMultipleTouchEnabled = true
        trimmingView.alpha = 0
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        startPositionConstraint.constant = position(for: minSelectedValue)
        endPositionConstraint.constant = position(for: maxSelectedValue)
        thumbPositionConstraint.constant = position(for: thumbValue)
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        subview.isUserInteractionEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches where touch.phase == .began {
            if trackingControl.count >= 2 {
                break
            }
            var location = touch.location(in: self)
            guard
                trackingControl[touch] == nil,
                let control = nearestControl(to: location)
                else { continue }
            location.x -= position(for: control)
            initialPoint[touch] = location
            trackingControl[touch] = control
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard
                let trackingControl = trackingControl[touch],
                let initialPoint = initialPoint[touch]
                else { continue }
            let newValue = value(for: touch.location(in: self).x - initialPoint.x)
            switch trackingControl {
            case .start:
                minSelectedValue = newValue
                sendActions(for: .valueChanged)
                
            case .end:
                maxSelectedValue = newValue
                sendActions(for: .valueChanged)
                
            case .thumb:
                thumbValue = newValue
                thumbValueChanged?(thumbValue)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            trackingControl[touch] = nil
            initialPoint[touch] = nil
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            trackingControl[touch] = nil
            initialPoint[touch] = nil
        }
    }
    
    @IBAction private func tap(_ tapGR: UIGestureRecognizer) {
        if tapGR.location(in: self).y < backgroundView.frame.maxY {
            trimmingViewVisible.toggle()
        }
    }
    
    // MARK: - Helpers
    
    private func nearestControl(to point: CGPoint) -> TrackingControl? {
        let controls: [TrackingControl]
        if trimmingViewVisible {
            controls = TrackingControl.allCases
        } else {
            controls = [.thumb]
        }
        var nearestControl: (TrackingControl?, CGFloat) = (nil, .greatestFiniteMagnitude)
        controls.forEach { control in
            if let distance = frame(for: control).distanceFromRectMid(to: point),
                distance < nearestControl.1
            {
                nearestControl = (control, distance)
            }
        }
        return nearestControl.0
    }
    
    private func position(for value: Double) -> CGFloat {
        let result = (minPosition + (maxPosition - minPosition) * CGFloat((value - minValue) / (maxValue - minValue))).roundedScreenScaled
        return result.isFinite ? result : 0
    }
    
    private func value(for position: CGFloat) -> Double {
        let result = minValue + Double(position - minPosition) * (maxValue - minValue) / Double(maxPosition - minPosition)
        return result.isFinite ? result : 0
    }
    
    private func position(for trackingControl: TrackingControl) -> CGFloat {
        switch trackingControl {
        case .start:
            return startPositionConstraint.constant
            
        case .end:
            return endPositionConstraint.constant
            
        case .thumb:
            return thumbPositionConstraint.constant
        }
    }
    
    private func frame(for control: TrackingControl) -> CGRect {
        switch control {
        case .start:
            return startView.frame
            
        case .end:
            return endView.frame
            
        case .thumb:
            return thumbView.frame
        }
    }
    
}



