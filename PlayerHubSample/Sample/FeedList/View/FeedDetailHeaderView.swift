//
//  FeedDetailHeaderView.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/25.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class FeedDetailHeaderView: UIView {

    var didTouchToPlayHandler: (() -> Void)?
       
       
   private let userBar = FeedUserBar()
   
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(userBar)
        addSubview(titleLabel)
        addSubview(videoContainer)
        videoContainer.addSubview(videoImageView)
        videoContainer.addSubview(playButton)
        
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
            make.height.equalTo(120)
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
    
    func configure(with feed: Feed, preferedWidth: CGFloat) {
        userBar.avatarImageView.kf.setImage(with: feed.avatarURL)
        userBar.nameLabel.text = feed.authorName
        
        titleLabel.preferredMaxLayoutWidth = preferedWidth - 12 * 2
        titleLabel.text = feed.title
        videoImageView.kf.setImage(with: feed.imageURL)
    
        videoContainer.snp.remakeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
            if let width = feed.videoWidth, let height = feed.videoHeight {
                make.height.equalTo(preferedWidth * height / width)
            } else {
                make.height.equalTo(preferedWidth * defaultVideoRatio)
            }
        }
        
        // 通过相对高度关系，对于自动算高有点问题，直接写死高度就没有问题
    }
    
    
}
