//
//  PlayerBox.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/11.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class NormalPlayerController: PlayerControllable {
    enum FullScreenType {
        case auto
        case portrait
        case landscape
    }
    
    var fullScreenType = FullScreenType.auto
    let contentView = UIView()
    let playerView = PlayerView()
    
    let controlView = NormalPlayerControlView()
    
    // 全屏之前需要保存的参数
    private var originalSuperview: UIView?
    private var originalFrameInSuperview: CGRect?
    private var originalFrameInWindow: CGRect?
    
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
            
            self.originalSuperview = self.contentView.superview
            self.originalFrameInSuperview = self.contentView.frame
            self.originalFrameInWindow = self.contentView.superview?.convert(self.contentView.frame, to: window)
            
            self.contentView.removeFromSuperview()
            window.addSubview(self.contentView)
            if let frameBeforeFullScreen = self.originalFrameInWindow {
                self.contentView.frame = frameBeforeFullScreen
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                if self.isFullScreenLandscape() {
                    self.contentView.frame = CGRect(origin: CGPoint(), size: CGSize(width: window.bounds.height, height: window.bounds.width))
                    self.contentView.center = CGPoint(x: window.bounds.midX, y: window.bounds.midY)
                    self.contentView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                    print(self.contentView.frame)
                } else {
                    self.contentView.frame = window.bounds
                }
                self.contentView.setNeedsLayout()
                self.contentView.layoutIfNeeded()
                
            }) { _ in
                
            }
        }
        
        controlView.didTouchToExitFullScreenHandler = { [unowned self] in
            guard let originalSuperview = self.originalSuperview else {
                return
            }
            guard let originalFrameInWindow = self.originalFrameInWindow else {
                return
            }
            guard let originalFrameInSuperview = self.originalFrameInSuperview else {
                return
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                if self.isFullScreenLandscape() {
                    self.contentView.transform = CGAffineTransform.identity
                }
                self.contentView.frame = originalFrameInWindow
                self.contentView.setNeedsLayout()
                self.contentView.layoutIfNeeded()
            }) { _ in
                self.contentView.removeFromSuperview()
                
                originalSuperview.addSubview(self.contentView)
                self.contentView.frame = originalFrameInSuperview
            }
        }
    }
    
    private func isFullScreenLandscape() -> Bool {
        var isLandscape = false
        switch self.fullScreenType {
        case .auto:
            if let originalFrameInSuperview = originalFrameInSuperview {
                isLandscape = originalFrameInSuperview.width > originalFrameInSuperview.height
            }
        case .portrait:
            isLandscape = false
        case .landscape:
            isLandscape = true
        }
        return isLandscape
    }
    
}

extension NormalPlayerController {
    func replace(with url: URL, next: URL?, coverUrl: URL?, placeholder: UIImage?) {
        playerView.player.replace(with: url, preload: next)
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
