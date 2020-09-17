//
//  TimecodeCell.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Philip Dukhov on 9/17/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate

class WaveformGenerator {
    static let backgroundQueue = DispatchQueue(label: "WaveformGeneratorQueue")
    
    static func processSamples(fromData sampleBuffer: inout Data,
                               samplesToProcess: Int,
                               downSampledLength: Int,
                               samplesPerPixel: Int,
                               filter: [Float]) -> [CGFloat]
    {
        sampleBuffer.withUnsafeBytes { bytes in
            guard let samples = bytes.bindMemory(to: Float.self).baseAddress else {
                return []
            }
            
            let processingBuffer = UnsafeMutablePointer(mutating: samples)
            
            //Take the absolute values to get amplitude
            vDSP_vabs(processingBuffer, 1, processingBuffer, 1, .init(samplesToProcess))
            
            //Downsample and average
            
            let downSampledData = UnsafeMutablePointer<Float>.allocate(capacity: downSampledLength)
            vDSP_desamp(processingBuffer,
                        vDSP_Stride(samplesPerPixel),
                        filter,
                        downSampledData,
                        vDSP_Length(downSampledLength),
                        vDSP_Length(samplesPerPixel))
            sampleBuffer.removeFirst(samplesToProcess * MemoryLayout<Float>.size)
            return Array(UnsafeBufferPointer(start: downSampledData,
                                             count: downSampledLength)).map { .init($0) }
        }
    }
}
