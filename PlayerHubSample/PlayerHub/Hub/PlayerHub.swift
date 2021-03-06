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
    
    private(set) var controller: PlayerControllable!
    
    private init() {
        
    }
    
    func register(controller: PlayerControllable) {
        self.controller = controller
    }
    
    func clearRegistration() {
        self.controller.playerView.player.stop()
        self.controller.playerView.removeFromSuperview()
        self.controller = nil
    }
    
}

extension PlayerHub {
    func addPlayer(to container: UIView) {
        container.addSubview(controller.contentView)
        controller.contentView.frame = container.bounds
    }
    
    func movePlayer(to container: UIView) {
        controller.contentView.removeFromSuperview()
        
        addPlayer(to: container)
    }
    
    func removePlayer() {
        controller.contentView.removeFromSuperview()
    }
    
    func stop() {
        controller.playerView.player.stop()
    }
    
    func play() {
        controller.playerView.player.play()
    }

    func replace(with url: URL, next: URL?, coverUrl: URL?, placeholder: UIImage?) {
        controller.replace(with: url, next: next, coverUrl: coverUrl, placeholder: placeholder)
    }
    
    func isPlayer(in container: UIView) -> Bool {
        return controller.contentView.superview == container
    }
}
