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
    
    var controller: PlayerControlable!
    
    private init() {
        
    }
    
    func register(controller: PlayerControlable) {
        self.controller = controller
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

    func replace(with url: URL, coverUrl: URL?, placeholder: UIImage?) {
        controller.replace(with: url, coverUrl: coverUrl, placeholder: placeholder)
    }
    
    func playerIsIn(container: UIView) -> Bool {
        return controller.contentView.superview == container
    }
}
