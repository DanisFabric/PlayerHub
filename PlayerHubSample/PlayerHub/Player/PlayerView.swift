//
//  PlayerView.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/10.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit
import AVFoundation


class PlayerView: UIView {
    let player = Player()
    
    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        player.bind(to: layer as! AVPlayerLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        player.bind(to: layer as! AVPlayerLayer)
    }
}
