//
//  FullScreenCell.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/21.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit
import SnapKit

class FullScreenCell: UITableViewCell {
    var didTouchToPlayHandler: (() -> Void)?
    
    let videoContainer = UIView()
    let videoImageView = UIImageView()
    
    private let playButton: UIButton = {
        let temp = UIButton(type: .custom)
        temp.setImage(UIImage(named: "normal_player_play"), for: .normal)
        
        return temp
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        videoImageView.contentMode = .scaleAspectFit
        contentView.backgroundColor = UIColor.black
        
        contentView.addSubview(videoContainer)
        videoContainer.addSubview(videoImageView)
        videoContainer.addSubview(playButton)
        
        videoContainer.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        videoImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        playButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        playButton.addTarget(self, action: #selector(onTouch(playButton:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func onTouch(playButton: UIButton) {
        didTouchToPlayHandler?()
    }
}
