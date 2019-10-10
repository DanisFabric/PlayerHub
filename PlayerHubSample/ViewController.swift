//
//  ViewController.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/10.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var videoView: PlayerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoView.player.loopMode = .always
        videoView.player.statusDidChangeHandler = { status in
            print(status)
        }
        videoView.player.playedDurationDidChangeHandler = { played, total in
            print(String(format: "%.2f", played / total))
        }
        
    }

    @IBAction func onStart(_ sender: Any) {
        videoView.player.replace(with: URL(string: "http://flv3.bn.netease.com/tvmrepo/2018/6/9/R/EDJTRAD9R/SD/EDJTRAD9R-mobile.mp4")!)
        videoView.player.play()
    }
    
    @IBAction func onPlay(_ sender: Any) {
        videoView.player.play()
    }
    @IBAction func onPause(_ sender: Any) {
        videoView.player.pause()
    }
}

