//
//  PlayerHub.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/14.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit


class PlayerHub {
    static let shared = PlayerHub()
    
    let box = NormalPlayerBox()
    
    private init() {
        
    }
    
    
}

extension PlayerHub {
    func addBox(to container: UIView) {
        container.addSubview(box)
        box.frame = container.bounds
    }
    
    func moveBox(to container: UIView) {
        box.removeFromSuperview()
        
        addBox(to: container)
    }
    
    func removeBox() {
        box.removeFromSuperview()
    }
    
    func stop() {
        box.playerView.player.stop()
    }
    
    func play() {
        box.playerView.player.play()
    }

    
    func replace(with url: URL) {
        box.playerView.player.replace(with: url)
    }
}
