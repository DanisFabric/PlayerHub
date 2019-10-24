//
//  PlayerBox.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/11.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class NormalPlayerController: PlayerControlable {
    
    let contentView = UIView()
    let playerView = PlayerView()
    
    let controlView = NormalPlayerControlView()
    
    private var superviewBeforeFullScreen: UIView?
    private var frameBeforeFullScreen: CGRect?
    
    deinit {
        print("deinit")
    }
    
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
        
        controlView.didTouchToEnterFullScreenHandler = { [unowned self] in
            guard let window = UIApplication.shared.keyWindow else {
                return
            }
            self.superviewBeforeFullScreen = self.contentView.superview
            self.frameBeforeFullScreen = self.contentView.superview?.convert(self.contentView.frame, to: window)
            
            self.contentView.removeFromSuperview()
            
            window.addSubview(self.contentView)
            if let frameBeforeFullScreen = self.frameBeforeFullScreen {
                self.contentView.frame = frameBeforeFullScreen
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.contentView.frame = window.bounds
                self.contentView.setNeedsLayout()
                self.contentView.layoutIfNeeded()
                
            }) { _ in
                
            }
        }
        
        controlView.didTouchToExitFullScreenHandler = { [unowned self] in
            guard let superviewBeforeFullScreen = self.superviewBeforeFullScreen else {
                return
            }
            guard let frameBeforeFullScreen = self.frameBeforeFullScreen else {
                return
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.contentView.frame = frameBeforeFullScreen
                self.contentView.setNeedsLayout()
                self.contentView.layoutIfNeeded()
            }) { _ in
                self.contentView.removeFromSuperview()
                
                superviewBeforeFullScreen.addSubview(self.contentView)
                self.contentView.frame = superviewBeforeFullScreen.bounds
            }
        }
    }
    
}

extension NormalPlayerController {
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
