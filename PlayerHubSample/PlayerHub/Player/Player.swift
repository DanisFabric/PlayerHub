//
//  Player.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/10.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation
import AVFoundation

class Player: NSObject {
    enum Status {
        case initial        // 初始状态
        case preparing      // 装载了Item，但并未开始播放
        case buffering      // 加载中
        case playing        // 播放中
        case paused         // 暂停
        case end            // 播放到末尾
        case failed         // 播放出错
    }
    
    enum LoopMode {
        case never
        case always
    }
    
    var statusDidChangeHandler: ((Status) -> Void)?
    var playedDurationDidChangeHandler: ((TimeInterval, TimeInterval) -> Void)?
    var bufferedDurationDidChangeHandler: ((TimeInterval, TimeInterval) -> Void)?
    
    private let player: AVPlayer = {
        let temp = AVPlayer()
        temp.automaticallyWaitsToMinimizeStalling = false
        
        return temp
    }()
    
    private(set) var currentItem: AVPlayerItem?
    private(set) var duration: TimeInterval = 0
    private(set) var playedDuration: TimeInterval = 0 {
        didSet {
            playedDurationDidChangeHandler?(playedDuration, duration)
        }
    }
    private(set) var status = Status.initial {
        didSet {
            if status != oldValue {
                statusDidChangeHandler?(status)
                
                if status == .end && loopMode == .always {
                    seek(to: 0)
                    play()
                }
            }
        }
    }
    private(set) var error: Error?
    
    var loopMode = LoopMode.never
    
    
    // Private
    private var playerObservations = [NSKeyValueObservation]()
    private var itemObservations = [NSKeyValueObservation]()
    private var timeObserver: Any?
    
    override init() {
        super.init()
        
        addPlayerObservers()
        addNotifications()
    }
    
    deinit {
        removeItemObservers()
        removePlayerObservers()
        removeNotifications()
    }
    
    
}

extension Player {
    func bind(to playerLayer: AVPlayerLayer) {
        playerLayer.player = player
    }
    
    func replace(with url: URL) {
        if currentItem != nil {
            stop()
        }
        
        currentItem = AVPlayerItem(url: url)
        addItemObservers()
        
        player.replaceCurrentItem(with: currentItem)
    }
    
    func stop() {
        removeItemObservers()
        currentItem = nil
        player.replaceCurrentItem(with: nil)
        
        status = .initial
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func seek(to time: TimeInterval) {
        player.seek(to: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
}

extension Player {
    private func addNotifications() {}
    
    private func removeNotifications() {}
    
    private func addPlayerObservers() {
        let ob1 = player.observe(\.status, options: .new) { [unowned self] (player, change) in
            self.updateStatus()
        }
        
        let ob2 = player.observe(\.timeControlStatus, options: .new) { [unowned self] (player, change) in
            self.updateStatus()
        }
        
        playerObservations = [ob1, ob2]
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.03, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [unowned self] (time) in
            guard let total = self.currentItem?.duration.seconds else {
                return
            }
            if total.isNaN || total.isZero {
                return
            }
            
            self.duration = total
            self.playedDuration = time.seconds
        })
    }
    
    private func removePlayerObservers() {
        playerObservations.forEach {
            $0.invalidate()
        }
        playerObservations.removeAll()
    }
    
    private func addItemObservers() {
        guard let currentItem = currentItem else {
            return
        }
        
        let ob1 = currentItem.observe(\.status, options: .new) { [unowned self] (item, change) in
            self.updateStatus()
        }
        let ob2 = currentItem.observe(\.loadedTimeRanges, options: .new) { [unowned self] (item, change) in
            if let range = item.loadedTimeRanges.first as? CMTimeRange {
                self.bufferedDurationDidChangeHandler?(range.start.seconds, range.duration.seconds)
            }
        }
        
        itemObservations = [ob1, ob2]
    }
    
    private func removeItemObservers() {
        itemObservations.forEach {
            $0.invalidate()
        }
        itemObservations.removeAll()
    }
    
    private func updateStatus() {
        guard let currentItem = currentItem else {
            return
        }
        
        if let error = player.error {
            self.status = .failed
            self.error = error
            
            return
        }
        
        if let error = currentItem.error {
            self.status = .failed
            self.error = error
            
            return
        }
        
        self.error = nil
        
        switch player.timeControlStatus {
        case .playing:
            status = .playing
        case .paused:
            if status == .initial && currentItem.currentTime().seconds == 0 {
                status = .preparing
            } else if currentItem.currentTime() == currentItem.duration {
                status = .end
            } else {
                status = .paused
            }
        case .waitingToPlayAtSpecifiedRate:
            status = .buffering
        default:
            break
        }
    }
}

extension Player {

}
