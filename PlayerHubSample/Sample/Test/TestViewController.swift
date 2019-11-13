//
//  TestViewController.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/25.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    private let startButton: UIButton = {
        let temp = UIButton(type: .system)
        temp.setTitle("开始", for: .normal)
        
        return temp
    }()
    
    private let stopButton: UIButton = {
        let temp = UIButton(type: .system)
        temp.setTitle("暂停", for: .normal)
        
        return temp
    }()
    
    private let urls = DataCreator.createFeeds().map { (feed) -> URL in
        return feed.videoURL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(startButton)
        view.addSubview(stopButton)
        
        
        startButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(view.snp.centerX).offset(-12)
        }

        stopButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(view.snp.centerX).offset(12)
        }
        
        startButton.addTarget(self, action: #selector(onTouch(startButton:)), for: .touchUpInside)
    }
    
    
    @objc private func onTouch(startButton: UIButton) {
        
    }
    
    @objc private func onTouch(stopButton: UIButton) {
        
    }
    

}
