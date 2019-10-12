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
        
        playerView.player.bufferedDurationDidChangeHandler = { start, buffered, total in
            self.controlView.configure(bufferedDuration: start + buffered)
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
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NormalPlayerBox {
    func replace(with url: URL) {
        playerView.player.replace(with: url)
    }
}
