//
//  TimecodeCell.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Philip Dukhov on 9/17/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import AVFoundation
import UIKit

class AssetWaveformGenerator {
    let asset: AVAsset
    let audioMix: AVAudioMix
    
    private var cancelled = false
    
    func cancel() {
        cancelled = true
    }
    
    init(asset: AVAsset, audioMix: AVAudioMix) {
        self.asset = asset
        self.audioMix = audioMix
    }
    
    func generateSamples(count: Int, _ completion: @escaping ([CGFloat]) -> Void) {
        WaveformGenerator.backgroundQueue.async {
            let result = self.sliceAsset(downsampleTo: count)
            if !self.cancelled {
                completion(result)
            }
        }
    }
    
    private func sliceAsset(downsampleTo targetSamples: Int, specificSample: Int? = nil) -> [CGFloat] {
        var waveformSamples = [CGFloat]()
        guard
            asset.duration.seconds > 0,
            let reader = try? AVAssetReader(asset: asset)
            else { return waveformSamples }
        let channelCount = 1
        
        let sampleRate: Double = 44100
        let outputSettingsDict: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMIsNonInterleaved: false,
            AVNumberOfChannelsKey: channelCount,
            AVSampleRateKey: sampleRate,
        ]
        
        let readerOutput = AVAssetReaderAudioMixOutput(audioTracks: asset.tracks, audioSettings: outputSettingsDict)
        readerOutput.audioMix = audioMix
        readerOutput.alwaysCopiesSampleData = false
        reader.add(readerOutput)
        
        let timescale = asset.duration.timescale
        let totalSamples = Int(sampleRate * .init(asset.duration.value) / .init(timescale))
        
        let samplesPerPixel = max(1, channelCount * totalSamples / targetSamples)
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)
        
        var sampleBuffer = Data()
        
        if let specificSample = specificSample {
            func seconds(for sample: Int) -> TimeInterval {
                .init(sampleRate * .init(samplesPerPixel * sample))
            }
            reader.timeRange = .init(start: .init(seconds: seconds(for: specificSample),
                                                  preferredTimescale: timescale),
                                     end: .init(seconds: seconds(for: specificSample + 1),
                                                preferredTimescale: timescale))
        }
        reader.startReading()
        defer { reader.cancelReading() } // Cancel reading if we exit early or if operation is cancelled
        
        while reader.status == .reading {
            guard !cancelled else { return waveformSamples }
            
            guard let readSampleBuffer = readerOutput.copyNextSampleBuffer(),
                let readBuffer = CMSampleBufferGetDataBuffer(readSampleBuffer) else {
                    break
            }
            // Append audio sample buffer into our current sample buffer
            var readBufferLength = 0
            var readBufferPointer: UnsafeMutablePointer<Int8>?
            CMBlockBufferGetDataPointer(readBuffer, atOffset: 0, lengthAtOffsetOut: &readBufferLength, totalLengthOut: nil, dataPointerOut: &readBufferPointer)
            sampleBuffer.append(UnsafeBufferPointer(start: readBufferPointer, count: readBufferLength))
            CMSampleBufferInvalidate(readSampleBuffer)
            
            let totalSamples = sampleBuffer.count / MemoryLayout<Float>.size
            let downSampledLength = totalSamples / samplesPerPixel
            let samplesToProcess = downSampledLength * samplesPerPixel
            
            guard samplesToProcess > 0 else { continue }
            
            waveformSamples += WaveformGenerator.processSamples(fromData: &sampleBuffer,
                                                                samplesToProcess: samplesToProcess,
                                                                downSampledLength: downSampledLength,
                                                                samplesPerPixel: samplesPerPixel,
                                                                filter: filter)
        }
        
        // Process the remaining samples that did not fit into samplesPerPixel at the end
        let samplesToProcess = sampleBuffer.count / MemoryLayout<Float>.size
        if waveformSamples.count != targetSamples, !cancelled, samplesToProcess > 0 {
            let samplesPerPixel = samplesToProcess
            let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)
            waveformSamples += WaveformGenerator.processSamples(fromData: &sampleBuffer,
                                                                samplesToProcess: samplesToProcess,
                                                                downSampledLength: 1,
                                                                samplesPerPixel: samplesPerPixel,
                                                                filter: filter)
        }
        
        // normalize
        let max = waveformSamples.max()!
        waveformSamples = waveformSamples.map { $0 / max }
        
        if reader.status != .completed {
            print("\(#function) failed to read audio: \(String(describing: reader.error))")
        }
        return waveformSamples
    }
}
