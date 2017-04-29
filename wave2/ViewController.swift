//
//  ViewController.swift
//  wave2
//
//  Created by 若狭　健太 on 2017/04/23.
//  Copyright © 2017年 wakasa. All rights reserved.
//

import UIKit
import Accelerate
import Charts

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        let audioClass = AudioDataClass(address: "/Users/wakasakenta/Desktop/C001NaC4f1.wav")
        //読み込み
        audioClass.loadAudioData()
        
        // 標本化数
        let numSamples = 44100
        // サンプルデータ
        var samples = [Float](repeating: 0, count: 44100)
        
        for n in 0..<numSamples {
            samples[n] = audioClass.buffer[0][n]
        }
        
        var reals = [Float](repeating: 0, count: numSamples/2)
        var imgs  = [Float](repeating: 0, count: numSamples/2)
        var splitComplex = DSPSplitComplex(realp: &reals, imagp: &imgs)
        let src = UnsafeRawPointer(samples).bindMemory(to: DSPComplex.self, capacity: numSamples/2)
        vDSP_ctoz(src, 2, &splitComplex, 1, vDSP_Length(numSamples/2))
        
        //  Create FFT setup
        // __Log2nは log2(64) = 6 より、6 を指定
        
        let fftLevel = 512 //fftのポイント数を指定
        let log2fftLevel = vDSP_Length(log2(Double(fftLevel))) //fftのポイント数をlog2に変換
        
        let setup = vDSP_create_fftsetup(log2fftLevel, FFTRadix(FFT_RADIX2))
        // Perform FFT
        vDSP_fft_zrip(setup!, &splitComplex, 1, log2fftLevel, FFTDirection(FFT_FORWARD))
        
        // splitComplex.realp, splitComplex.imagpの各要素を1/2倍する
        var scale:Float = 1 / 2
        vDSP_vsmul(splitComplex.realp, 1, &scale, splitComplex.realp, 1, vDSP_Length(numSamples/2))
        vDSP_vsmul(splitComplex.imagp, 1, &scale, splitComplex.imagp, 1, vDSP_Length(numSamples/2))
        // 複素数の実部と虚部を取得する
        let r = Array(UnsafeBufferPointer(start: splitComplex.realp, count: numSamples/2))
        let i = Array(UnsafeBufferPointer(start: splitComplex.imagp, count: numSamples/2))

        var mag = [Double]() //周波数の強度を格納
        var xAxis = [Double]() //x軸の対応関係
        
        for n in 0..<fftLevel/2 {
            let rel = r[n]
            let img = i[n]
            let magSub = sqrtf(rel * rel + img * img)
            mag.append(Double(magSub))                                //配列に格納
            xAxis.append(Double(numSamples) / Double(fftLevel) * Double(n))
            
            let log = "[%02d]: Mag: %5.2f, Rel: %5.2f, Img: %5.2f"
            print(String(format: log, n, magSub, rel, img))
        }
        

        
        var rect = view.bounds
        //表示位置
        rect.origin.y += 50
        rect.size.height -= 200
        let lineChartView = LineChartView(frame: rect) //棒グラフの宣言
        
        

        //xとyの値の格納
        var entry = [BarChartDataEntry]()
        for index in 0..<fftLevel/2 {
            entry.append(BarChartDataEntry(x: Double(xAxis[index]), y: 10 * log10(mag[index]) ))
        }
        
        //datasetとして書き出す
        let set: LineChartDataSet =  LineChartDataSet(values: entry, label: "Data")
        set.drawCirclesEnabled = false
        
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set)
        
        lineChartView.data = LineChartData(dataSets: dataSets)
        view.addSubview(lineChartView)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

