//
//  FeedCell.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/24.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit
import Kingfisher

class FeedCell: UITableViewCell {
    private class UserBar: UIView {
        let avatarImageView: UIImageView = {
            let temp = UIImageView()
            temp.backgroundColor = UIColor(hex: 0xeeeeee)
            
            return temp
        }()
        
        let nameLabel: UILabel = {
            let temp = UILabel()
            temp.textColor = UIColor.black
            temp.font = UIFont.systemFont(ofSize: 16)
            
            return temp
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(avatarImageView)
            addSubview(nameLabel)
            
            avatarImageView.layer.cornerRadius = 16
            avatarImageView.layer.masksToBounds = true
            avatarImageView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(12)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(32)
            }
            
            nameLabel.snp.makeConstraints { (make) in
                make.left.equalTo(avatarImageView.snp.right).offset(8)
                make.centerY.equalTo(avatarImageView)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var didTouchToPlayHandler: (() -> Void)?
    
    
    private let userBar = UserBar()
    
    let titleLabel: UILabel = {
        let temp = UILabel()
        temp.textColor = UIColor.black
        temp.font = UIFont.systemFont(ofSize: 16)
        temp.numberOfLines = 0
        
        return temp
    }()
    
    let videoContainer: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.black
        
        return temp
    }()
    
    let videoImageView: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        temp.clipsToBounds = true
        
        return temp
    }()
    
    private let playButton: UIButton = {
        let temp = UIButton(type: .custom)
        temp.setImage(UIImage(named: "normal_player_play"), for: .normal)
        
        return temp
    }()
    
    private let defaultVideoRatio: CGFloat = 9.0 / 16
    
    private let separatorView: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor(hex: 0xdddddd)
        
        return temp
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userBar)
        contentView.addSubview(titleLabel)
        contentView.addSubview(videoContainer)
        videoContainer.addSubview(videoImageView)
        videoContainer.addSubview(playButton)
        contentView.addSubview(separatorView)
        
        userBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userBar.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        
        videoContainer.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(videoContainer.snp.width).multipliedBy(defaultVideoRatio)
        }
        
        separatorView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(16)
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
    
    func configure(with feed: Feed) {
        userBar.avatarImageView.kf.setImage(with: feed.avatarURL)
        userBar.nameLabel.text = feed.authorName
        
        titleLabel.text = feed.title
        videoImageView.kf.setImage(with: feed.imageURL)
    
        videoContainer.snp.remakeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
            if let width = feed.videoWidth, let height = feed.videoHeight {
                make.height.equalTo(videoContainer.snp.width).multipliedBy(height / width)
            } else {
                make.height.equalTo(videoContainer.snp.width).multipliedBy(defaultVideoRatio)
            }
        }
    }
}
