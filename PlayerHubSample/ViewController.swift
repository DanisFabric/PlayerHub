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
    @IBOutlet weak var slider: PlayerSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoView.player.loopMode = .always
        videoView.player.statusDidChangeHandler = { status in
            print(status)
        }
        videoView.player.playedDurationDidChangeHandler = { [unowned self] played, total in
            self.slider.playedProgress = played / total
        }
        videoView.player.bufferedDurationDidChangeHandler = { [unowned self] start, loaded, totalDuration in
            self.slider.bufferedProgress = (start + loaded) / totalDuration
        }
        
        slider.addTarget(self, action: #selector(onSliderChanged(slider:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(onSliderTouchUp(slider:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(onSliderTouchUp(slider:)), for: .touchUpOutside)
    }

    @IBAction func onStart(_ sender: Any) {
        let longVideo = "https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"
        let shortVideo = "http://flv3.bn.netease.com/tvmrepo/2018/6/9/R/EDJTRAD9R/SD/EDJTRAD9R-mobile.mp4"
        videoView.player.replace(with: URL(string: longVideo)!)
        videoView.player.play()
    }
    
    @IBAction func onPlay(_ sender: Any) {
        videoView.player.play()
    }
    @IBAction func onPause(_ sender: Any) {
        videoView.player.pause()
    }
    
    @objc private func onSliderChanged(slider: PlayerSlider) {
        print("value changed ---> \(slider.playedProgress)")
    }
    
    @objc private func onSliderTouchUp(slider: PlayerSlider) {
        print("touch up =======> \(slider.playedProgress)")
    }
}

