//
//  file.swift
//  wave2
//
//  Created by 若狭　健太 on 2017/04/29.
//  Copyright © 2017年 wakasa. All rights reserved.
//

writeAudioFile = try AVAudioFile(forWriting: NSURL(fileURLWithPath: address), settings: [
    AVFormatIDKey:Int(kAudioFormatLinearPCM), // file format
    AVSampleRateKey:audioformat!.sampleRate,
    AVNumberOfChannelsKey:nChannel,
    AVEncoderBitRatePerChannelKey:16 // 16bit
    ])
