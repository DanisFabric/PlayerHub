//
//  DouyinPlayerController.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/25.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit


class DouyinPlayerController: PlayerControllable {
    var gravity: Player.Gravity = .scaleAspectFit
    
    var playerView = PlayerView()
    
    let contentView = UIView()
    
    let controlView = DouyinPlayerControlView()
    
    init() {
        contentView.backgroundColor = UIColor.black
        
        contentView.addSubview(playerView)
        contentView.addSubview(controlView)
        
        playerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        controlView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        playerView.player.statusDidChangeHandler = { [unowned self] status in
            self.controlView.configure(with: status)
        }
        
        controlView.didTouchToPlayHandler = { [unowned self] in
            self.playerView.player.play()
        }
        
        controlView.didTouchToPauseHandler = { [unowned self] in
            self.playerView.player.pause()
        }
    }
    
    func replace(with url: URL, coverUrl: URL?, placeholder: UIImage?) {
        playerView.player.replace(with: url)
        controlView.configure(cover: coverUrl, placeholder: placeholder)
    }
}
