//
//  AudioFile.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Philip Dukhov on 9/16/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import Foundation
import AVFoundation

extension TimeInterval {
    var timeString: String {
        String(format: "%02d:%02d", Int(self) / 60 , Int(rounded()) % 60)
    }
}

struct AudioFile {
    struct Timecode: Identifiable, Equatable {
        let id: String = UUID().uuidString
        
        var title: String
        var startTime: TimeInterval
        
        mutating func updateStartTime(with startTimeString: String) {
            let values = startTimeString.split(separator: ":").compactMap { Int($0) }
            var multiplier = 1
            startTime = values
                .reversed()
                .reduce(into: 0) { timestamp, value in
                    timestamp += Double(value * multiplier)
                    multiplier *= 60
            }
        }
    }
    let url: URL
    private let asset: AVAsset
    
    var backgroundAudio: URL?
    
    var rampAtTheEnd = false
    var rampAtTheStart = false
    var segments: [ClosedRange<TimeInterval>]
    
    private var _timecodes: [Timecode]
    var timecodes: [Timecode] {
        set { _timecodes = newValue.sorted { $0.startTime < $1.startTime }}
        get { _timecodes }
    }
    
    init(url: URL) {
        self.url = url
        asset = AVURLAsset(url: url)
        segments = [0...asset.duration.seconds]
        _timecodes = []
    }
    
    func generateAudioInfo() throws -> (AVComposition, AVAudioMix) {
        let composition = AVMutableComposition()
        let compositionTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )!
        let assetTrack = asset.tracks(withMediaType: .audio).first!
        try segments.forEach { segment in
            try compositionTrack.insertTimeRange(
                segment.cmTimeRange(preferredTimescale: asset.duration.timescale),
                of: assetTrack,
                at: .invalid)
        }
        if let backgroundAudio = backgroundAudio,
            case let backgroundAsset = AVURLAsset(url: backgroundAudio),
            let backgroundTrack = backgroundAsset.tracks(withMediaType: .audio).first
        {
            let duration = min(backgroundAsset.duration, composition.duration)
            try composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
            )!
                .insertTimeRange(
                    .init(start: .zero, end: duration),
                    of: backgroundTrack,
                    at: .zero
            )
        }
        let audioMix = AVMutableAudioMix()
        audioMix.inputParameters = composition.tracks.map { track in
            let audioMixInputParameters = AVMutableAudioMixInputParameters()
            audioMixInputParameters.trackID = track.trackID
            let duration = max(2, composition.duration.seconds / 10)
            let timescale = composition.duration.timescale
            audioMixInputParameters.setVolume(1, at: .zero)
            if rampAtTheStart {
                audioMixInputParameters.setVolumeRamp(
                    fromStartVolume: 0,
                    toEndVolume: 1,
                    timeRange: (0...duration)
                        .cmTimeRange(preferredTimescale: timescale)
                )
            }
            if rampAtTheEnd {
                audioMixInputParameters.setVolumeRamp(
                    fromStartVolume: 1,
                    toEndVolume: 0,
                    timeRange: ((-duration...0) + composition.duration.seconds)
                        .cmTimeRange(preferredTimescale: timescale)
                )
            }
            return audioMixInputParameters
        }
        return (composition, audioMix)
    }
    
    mutating func crop(range: ClosedRange<TimeInterval>) {
        let (asset, _) = try! generateAudioInfo()
        var originalStart: TimeInterval!
        var originalEnd: TimeInterval!
        let cmRange = range.cmTimeRange(preferredTimescale: asset.duration.timescale)
        asset.tracks[0].segments.forEach { segment in
            if segment.timeMapping.target.containsTime(cmRange.start) {
               originalStart = (segment.timeMapping.source.start + cmRange.start - segment.timeMapping.target.start).seconds
            }
            if segment.timeMapping.target.containsTime(cmRange.end) {
                originalEnd = (segment.timeMapping.source.start + cmRange.end - segment.timeMapping.target.start).seconds
            }
        }
        let originalRange = originalStart...originalEnd
        let startSegmentIndex = segments.firstIndex { $0.contains(originalRange.lowerBound) }!
        let endSegmentIndex = segments.lastIndex { $0.contains(originalRange.upperBound) }!
        let firstOldSegment = segments[startSegmentIndex]
        let lastOldSegment = segments[endSegmentIndex]
        var newSegments = [ClosedRange<TimeInterval>]()
        if firstOldSegment.lowerBound < originalRange.lowerBound {
            newSegments.append(firstOldSegment.lowerBound...originalRange.lowerBound)
        }
        if originalRange.upperBound < lastOldSegment.upperBound {
            newSegments.append(originalRange.upperBound...lastOldSegment.upperBound)
        }
        segments.removeSubrange(startSegmentIndex...endSegmentIndex)
        segments.insert(contentsOf: newSegments, at: startSegmentIndex)
        print(Int(range.lowerBound), Int(range.upperBound), Int(originalRange.lowerBound), Int(originalRange.upperBound), segments.map { range in "\(Int(range.lowerBound)) \(Int(range.upperBound))" })
    }
}

extension TimeInterval {
    func cmTime(preferredTimescale: CMTimeScale) -> CMTime {
        CMTime(seconds: self, preferredTimescale: preferredTimescale)
    }
}

extension ClosedRange where Bound == TimeInterval {
    func cmTimeRange(preferredTimescale: CMTimeScale) -> CMTimeRange {
        CMTimeRange(
            start: lowerBound.cmTime(preferredTimescale: preferredTimescale),
            duration: (upperBound - lowerBound).cmTime(preferredTimescale: preferredTimescale)
        )
    }
    
    static func +(lhs: Self, rhs: Bound) -> Self {
        lhs.lowerBound + rhs...lhs.upperBound + rhs
    }
}
