//
//  DouyinPlayerControlView.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/25.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class DouyinPlayerControlView: UIView {
    var didTouchToPlayHandler: (() -> Void)?
    var didTouchToPauseHandler: (() -> Void)?
    
    let coverImageView: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        
        return temp
    }()
    
    let loadingView = DouyinLoadingView()
    
    private let playButton: UIButton = {
        let temp = UIButton(type: .custom)
        temp.setImage(UIImage(named: "normal_player_play"), for: .normal)
        
        return temp
    }()
    
    private var isStartedPlayingThrough = false
    
    private var status = Player.Status.initial
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(coverImageView)
        addSubview(loadingView)
        addSubview(playButton)
        
        coverImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        playButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.center.equalToSuperview()
        }
        
        playButton.addTarget(self, action: #selector(onTouch(playButton:)), for: .touchUpInside)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouch(background:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func onTouch(playButton: UIButton) {
        didTouchToPlayHandler?()
    }
    
    @objc private func onTouch(background tap: UITapGestureRecognizer) {
        if status == .playing {
            didTouchToPauseHandler?()            
        }
    }
}

extension DouyinPlayerControlView {
    func configure(cover url: URL?, placeholder: UIImage?) {
        coverImageView.kf.setImage(with: url, placeholder: placeholder)
    }
    
    func configure(with status: Player.Status) {
        self.status = status
        
        var isPlayable = false
        var isBuffering = false
        var isPlaying = false
        
        switch status {
        case .initial:
            isPlayable = false
        case .prepared:
            isPlayable = true
            self.isStartedPlayingThrough = false
        case .buffering:
            isPlayable = true
            isBuffering = true
        case .paused:
            isPlayable = true
        case .playing:
            isPlayable = true
            isPlaying = true
            
            self.isStartedPlayingThrough = true
        case .end:
            isPlayable = true
        case .failed:
            isPlayable = false
        }
        
        if isStartedPlayingThrough {
            coverImageView.isHidden = true
        } else {
            coverImageView.isHidden = false
        }
        
        if isPlayable {
            if isBuffering {
                playButton.isHidden = true
                loadingView.startAnimating()
            } else {
                playButton.isHidden = false
                loadingView.stopAnimating()
                
                if isPlaying {
                    playButton.isHidden = true
                } else {
                    playButton.isHidden = false
                }
            }
        } else {
            playButton.isHidden = true
        }
    }
}
