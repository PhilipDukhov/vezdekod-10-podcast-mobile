//
//  AudioPlayer.swift
//  TrackRecorder
//
//  Created by Philip Dukhov on 5/19/20.
//  Copyright © 2020 Philip Dukhov. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioPlayerDelegate: AnyObject {
    func audioPlayer(_ audioPlayer: AudioPlayer, statusChanged status: AudioPlayer.Status)
    func audioPlayer(_ audioPlayer: AudioPlayer, currentTimeChanged time: TimeInterval)
}

class AudioPlayer {
    enum Status {
        case paused
        case playing
    }
    
    var status: Status = .paused {
        didSet {
            guard status != oldValue else { return }
            delegate?.audioPlayer(self, statusChanged: status)
        }
    }
    var currentTime: TimeInterval { player.currentTime().seconds }
    weak var delegate: AudioPlayerDelegate? {
        didSet {
            delegate?.audioPlayer(self, statusChanged: status)
            delegate?.audioPlayer(self, currentTimeChanged: currentTime)
        }
    }
    
    func play() {
        player.play()
        status = .playing
    }
    
    func pause() {
        player.pause()
        status = .paused
    }
    
    func seek(_ time: TimeInterval, completion: (() -> Void)? = nil) {
        player.seek(to: .init(seconds: time,
                              preferredTimescale: player.currentItem?.duration.timescale ?? 44100))
        { _ in
            completion?() }
    }
    
    private var updatingAsset = false
    
    func setAsset(asset: AVAsset, audioMix: AVAudioMix) {
        updatingAsset = true
        routeUpdated()
        let currentTime = player.currentTime()
        let item = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: item)
        player.currentItem?.audioMix = audioMix
        let seekCompletion = { [weak self] in
            guard let self = self else { return }
            if self.status == .playing {
                self.player.play()
            }
            self.updatingAsset = false
            self.timeChanged()
        }
        if currentTime.value > 0 {
            player.seek(to: currentTime) {
                guard $0 else { return }
                seekCompletion()
            }
        } else {
            seekCompletion()
        }
    }
    
    // MARK: - Privates
    private let player = AVPlayer()
    private var notificationObservers = [NSObjectProtocol]()
    private var periodicTimeObservers = [Any]()
    
    init() {
        periodicTimeObservers = [
            player.addPeriodicTimeObserver(forInterval: .init(seconds: 1/60, preferredTimescale: 44000),
                                           queue: .main)
            { [weak self] _ in self?.timeChanged() },
        ]
        
        routeUpdated()
        notificationObservers += [
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: nil,
                                                   queue: .main)
            { [weak self] _ in self?.timeChanged() },
            NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification,
                                                   object: nil,
                                                   queue: .main)
            { [weak self] _ in self?.routeUpdated() },
        ]
    }
    
    deinit {
        periodicTimeObservers.forEach {
            player.removeTimeObserver($0)
        }
        notificationObservers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }
    
    private func routeUpdated() {
        guard let output = AVAudioSession.sharedInstance().currentRoute.outputs.first else { return }
        let overridePort: AVAudioSession.PortOverride
        if output.portType == .builtInSpeaker {
            player.volume = 0.05
            overridePort = .speaker
        } else {
            player.volume = 1
            overridePort = .none
        }
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(overridePort)
    }
    
    private func timeChanged() {
        guard !updatingAsset else { return }
        delegate?.audioPlayer(self, currentTimeChanged: currentTime)
    }
}
