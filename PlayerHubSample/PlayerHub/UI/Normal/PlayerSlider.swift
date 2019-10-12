//
//  PlayerSlider.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/11.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

extension PlayerSlider {
    private class TrackLayer: CALayer {
        var trackColor = UIColor.white
        
        override func draw(in ctx: CGContext) {
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2)
            
            ctx.setFillColor(trackColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        }
    }
    
    private class ThumbLayer: CALayer {
        var isHighlighted: Bool = false {
            didSet {
                setNeedsDisplay()
            }
        }
        
        var normalColor = UIColor.white
        var highlightedColor = UIColor.white
        
        override func draw(in ctx: CGContext) {
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2)
            
            if isHighlighted {
                ctx.setFillColor(highlightedColor.cgColor)
            } else {
                ctx.setFillColor(normalColor.cgColor)
            }
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        }
    }
}




class PlayerSlider: UIControl {
    var playedProgress: Double = 0 {
        didSet {
            updateLayerFrames()
        }
    }
    var bufferedProgress: Double = 0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var trackColor = UIColor.white.withAlphaComponent(0.2) {
        didSet {
            trackLayer.trackColor = trackColor
            
            trackLayer.setNeedsDisplay()
        }
    }
    
    var bufferedTrackColor = UIColor.white.withAlphaComponent(0.6) {
        didSet {
            bufferedTrackLayer.trackColor = bufferedTrackColor
            
            bufferedTrackLayer.setNeedsDisplay()
        }
    }
    
    var playedTrackColor = UIColor.white {
        didSet {
            playedTrackLayer.trackColor = playedTrackColor
            
            playedTrackLayer.setNeedsDisplay()
        }
    }
    
    var thumbNormalColor = UIColor.white {
        didSet {
            thumbLayer.normalColor = thumbNormalColor
            
            thumbLayer.setNeedsDisplay()
        }
    }
    
    var thumbHighlightedColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1) {
        didSet {
            thumbLayer.highlightedColor = thumbHighlightedColor
            
            thumbLayer.setNeedsDisplay()
        }
    }
    
    var thumbBorderColor = UIColor.black {
        didSet {
            
        }
    }
    
    var trackHeight: CGFloat = 2 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var thumbWidth: CGFloat = 12 {
        didSet {
            updateLayerFrames()
        }
    }
    
    // View
    private lazy var trackLayer = TrackLayer()
    
    private lazy var bufferedTrackLayer = TrackLayer()
    
    private lazy var playedTrackLayer = TrackLayer()
    
    private lazy var thumbLayer = ThumbLayer()
    
    private var previousTouchPoint = CGPoint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        trackLayer.trackColor = trackColor
        bufferedTrackLayer.trackColor = bufferedTrackColor
        playedTrackLayer.trackColor = playedTrackColor
        thumbLayer.normalColor = thumbNormalColor
        thumbLayer.highlightedColor = thumbHighlightedColor
        
        trackLayer.contentsScale = UIScreen.main.scale
        bufferedTrackLayer.contentsScale = UIScreen.main.scale
        playedTrackLayer.contentsScale = UIScreen.main.scale
        thumbLayer.contentsScale = UIScreen.main.scale
        
        layer.addSublayer(trackLayer)
        layer.addSublayer(bufferedTrackLayer)
        layer.addSublayer(playedTrackLayer)
        layer.addSublayer(thumbLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateLayerFrames()
    }
    
    private func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = CGRect(x: startX, y: (bounds.height - trackHeight) / 2, width: trackWidth, height: trackHeight)
        
        bufferedTrackLayer.frame = CGRect(x: trackLayer.frame.minX, y: trackLayer.frame.minY, width: trackLayer.frame.width * CGFloat(bufferedProgress), height: trackLayer.frame.height)
        
        playedTrackLayer.frame = CGRect(x: trackLayer.frame.minX, y: trackLayer.frame.minY, width: trackLayer.frame.width * CGFloat(playedProgress), height: trackLayer.frame.height)
        
        thumbLayer.frame = CGRect(x: position(of: playedProgress) - thumbWidth / 2, y: (bounds.height - thumbWidth) / 2, width: thumbWidth, height: thumbWidth)
        
        
        trackLayer.setNeedsDisplay()
        bufferedTrackLayer.setNeedsDisplay()
        playedTrackLayer.setNeedsDisplay()
        thumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousTouchPoint = touch.location(in: self)
        
        if thumbLayer.frame.insetBy(dx: -10, dy: -10).contains(previousTouchPoint) {
            thumbLayer.isHighlighted = true
            
            return true
        }
        return false
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let currentPoint = touch.location(in: self)
        
        let offsetX = currentPoint.x - previousTouchPoint.x
        
        let changedValue = value(between: offsetX)
        
        playedProgress = max(min(playedProgress + changedValue, 1), 0)
        
        previousTouchPoint = currentPoint

        sendActions(for: .valueChanged)
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if thumbLayer.isHighlighted {
            thumbLayer.isHighlighted = false
        }
    }
}

extension PlayerSlider {
    private var startX: CGFloat {
        return thumbWidth / 2
    }
    private var trackWidth: CGFloat {
        return bounds.width - thumbWidth
    }
    private func position(of value: Double) -> CGFloat {
        return startX + trackWidth * CGFloat(min(max(value, 0), 1))
    }
    
    private func value(of position: CGFloat) -> Double {
        return Double(max(min((position - startX) / trackWidth, 1), 0))
    }
    
    private func value(between offset: CGFloat) -> Double {
        return Double(offset / trackWidth)
    }
}
