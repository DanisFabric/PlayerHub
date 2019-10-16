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
    
    private init() {}
    
    let box = NormalPlayerBox()
    
}

extension PlayerHub {
    func add(to container: UIView) {
        container.addSubview(box)
        box.frame = container.bounds
    }
    
    func move(to container: UIView) {
        box.removeFromSuperview()
        
        add(to: container)
    }
    
    func remove() {
        box.removeFromSuperview()
    }
    
    func stop() {
        box.playerView.player.stop()
    }
    
    func play(url: URL) {
        box.playerView.player.replace(with: url)
    }
}
