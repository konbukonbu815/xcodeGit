//
//  class.swift
//  wave2
//
//  Created by 若狭　健太 on 2017/04/29.
//  Copyright © 2017年 wakasa. All rights reserved.
//

import Foundation
import AVFoundation

class AudioDataClass{
    
    //object for audio file
    var audioFile:AVAudioFile!
    
    //buffer for PCM data 便宜上AVAudioPCMBuffer型の変数を用意
    //クラス外から実際にバイナリデータにアクセスする際はbufferプロパティを使う。
    var PCMBuffer:AVAudioPCMBuffer!
    
    // audio file address
    var address:String
    
    //オーディオのバイナリデータを格納するためのbuffer, マルチチャンネルに対応するため、二次元配列になっています。
    var buffer:[[Float]]! = Array<Array<Float>>()
    
    //オーディオデータの情報
    var samplingRate:Double?
    var nChannel:Int?
    var nframe:Int?
    
    //initializer
    init(address:String){
        self.address = address
    }
}
