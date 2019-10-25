//
//  DouyinLoadingView.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/25.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class DouyinLoadingView: UIView {
    private let Animationkey = "LoadingAnimation"

    private let lineLayer: CALayer = {
        let temp = CALayer()
        temp.backgroundColor = UIColor.white.cgColor
        temp.isHidden = true
        
        return temp
    }()
    
    private(set) var isAnimating: Bool = false {
        didSet {
            lineLayer.isHidden = !isAnimating
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.addSublayer(lineLayer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lineLayer.frame = bounds
    }
}

extension DouyinLoadingView {
    
    func startAnimating() {
        isAnimating = true
        
        let group = CAAnimationGroup()
        group.duration = 0.6
        group.repeatCount = Float.infinity
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let shrinkAnim = CABasicAnimation(keyPath: "transform.scale.x")
        shrinkAnim.fromValue = 0.01
        shrinkAnim.toValue = 1
        
        let alphaAnim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        alphaAnim.fromValue = 1
        alphaAnim.toValue = 0.3
        
        group.animations = [shrinkAnim, alphaAnim]
        
        lineLayer.add(group, forKey: Animationkey)
    }
    
    func stopAnimating() {
        isAnimating = false
        
        lineLayer.removeAnimation(forKey: Animationkey)
    }
}
