//
//  PlayerBox.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/11.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class NormalPlayerBox: UIView {
    let playerView = PlayerView()
    
    let controlView = NormalPlayerControlView()
    
    deinit {
        print("deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black
        
        addSubview(playerView)
        addSubview(controlView)
        
        playerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        controlView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        playerView.player.statusDidChangeHandler = { [unowned self] status in
            self.controlView.configure(with: status)
        }
        
        playerView.player.playedDurationDidChangeHandler = { [unowned self] played, total in
            self.controlView.configure(totalDuration: total)
            self.controlView.configure(playedDuration: played)
        }
        
        playerView.player.bufferedDurationDidChangeHandler = { [unowned self] range in
            self.controlView.configure(bufferedDuration: range.upperBound)
        }
        
        
        controlView.didTouchToPlayHandler = { [unowned self] in
            self.playerView.player.play()
        }
        
        controlView.didTouchToPauseHandler = { [unowned self] in
            self.playerView.player.pause()
        }
        
        controlView.didTouchWillSeekHandler = { [unowned self] in
            self.playerView.player.pause()
        }
        
        controlView.didTouchToSeekHandler = { [unowned self] playedDuration in
            self.playerView.player.seek(to: playedDuration)
            self.playerView.player.play()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NormalPlayerBox {
    func replace(with url: URL, coverUrl: URL?, placeholder: UIImage?) {
        playerView.player.replace(with: url)
        controlView.configure(cover: coverUrl, placeholder: placeholder)
    }
    
    var gravity: Player.Gravity {
        get {
            return playerView.player.gravity
        }
        set {
            playerView.player.gravity = newValue
            controlView.coverImageView.contentMode = newValue.imageContentMode
        }
    }
}
