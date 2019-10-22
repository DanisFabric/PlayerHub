//
//  Player.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/10.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class Player: NSObject {
    enum Status {
        case initial        // 初始状态
        case prepared       // 装载了Item，但并未开始播放
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
    
    // loadedStart, loadedDuration, totalDuration
    var bufferedDurationDidChangeHandler: ((TimeInterval, TimeInterval, TimeInterval) -> Void)?
    
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
                
                print("status changed -> \(status)")
                
                if status == .end && loopMode == .always {
                    seek(to: 0)
                    play()
                }
            }
        }
    }
    private(set) var error: Error?
    
    var loopMode = LoopMode.never
    
    private var toPlay = false
    private let startPlayingAfterPreBufferingDuration: TimeInterval = 2 // 缓存2秒内容进行播放
    
    // Private
    private var playerObservations = [NSKeyValueObservation]()
    private var itemObservations = [NSKeyValueObservation]()
    private var timeObserver: Any?
    
    private var isPlayingWhenEnterBackground = false
    private var isPlayingWhenResignActive = false
    var isPlaying: Bool {
        return player.rate != 0
    }
    
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
        toPlay = false
        removeItemObservers()
        currentItem = nil
        player.replaceCurrentItem(with: nil)
        
        status = .initial
    }
    
    func play() {
        toPlay = true
        
        player.play()
    }
    
    func pause() {
        toPlay = false
        
        player.pause()
    }
    
    func seek(to time: TimeInterval) {
        player.seek(to: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), toleranceBefore: .zero, toleranceAfter: .zero)
    }
}

extension Player {
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
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
        
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
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
                self.bufferedDurationDidChangeHandler?(range.start.seconds, range.duration.seconds, self.duration)
                
                if self.status == .buffering {
                    if range.start.seconds + range.duration.seconds == currentItem.duration.seconds { // 到末尾
                        self.play()
                    } else if range.start.seconds + range.duration.seconds > currentItem.currentTime().seconds + self.startPlayingAfterPreBufferingDuration {    // 多加载了1秒
                        self.play()
                    }
                }
            }
        }
        let ob3 = currentItem.observe(\.isPlaybackLikelyToKeepUp, options: .new) { [unowned self] (item, change) in
            self.updateStatus()
        }
        let ob4 = currentItem.observe(\.isPlaybackBufferEmpty, options: .new) { [unowned self] (item, change) in
            self.updateStatus()
        }
        let ob5 = currentItem.observe(\.isPlaybackBufferFull, options: .new) { [unowned self] (item, change) in
            self.updateStatus()
        }
        
        itemObservations = [ob1, ob2, ob3, ob4, ob5]
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
        
        if toPlay { // 期望播放
            if currentItem.isPlaybackLikelyToKeepUp && player.rate != 0 {
                self.status = .playing
            } else {
                self.status = .buffering
            }
        } else {
            if status == .initial || status == .prepared && currentItem.currentTime().seconds == 0 {
                status = .prepared
            } else if currentItem.currentTime() == currentItem.duration {
                status = .end
            } else {
                status = .paused
            }
        }
        
    }
}

extension Player {
    @objc private func onNotificationEnterBackground(_ noti: Notification) {
        isPlayingWhenEnterBackground = isPlaying
        
        if isPlaying {
            pause()
        }
    }
    
    @objc private func onNotificationEnterForeground(_ noti: Notification) {
        if isPlayingWhenEnterBackground {
            play()
        }
    }
    
    @objc private func onNotificationResignActive(_ noti: Notification) {
        isPlayingWhenResignActive = isPlaying
        
        if isPlaying {
            pause()
        }
    }
    
    @objc private func onNotificationBecomeActive(_ noti: Notification) {
        if isPlayingWhenResignActive {
            play()
        }
    }
}
    
