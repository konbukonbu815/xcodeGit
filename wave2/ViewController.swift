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
        
        // 標本化数
        let numSamples = 1024
        // サンプルデータ
        var samples = [Float](repeating: 0, count: 1024)
        
        for n in 0..<numSamples {
            samples[n] = (0.25 * sinf(Float(M_PI) * Float(n) / 8.0)) + (0.25 * sinf(Float(M_PI) * Float(n) / 16.0))
        }
        
        var reals = [Float](repeating: 0, count: numSamples/2)
        var imgs  = [Float](repeating: 0, count: numSamples/2)
        var splitComplex = DSPSplitComplex(realp: &reals, imagp: &imgs)
        let src = UnsafeRawPointer(samples).bindMemory(to: DSPComplex.self, capacity: numSamples/2)
        vDSP_ctoz(src, 2, &splitComplex, 1, vDSP_Length(numSamples/2))
        
        //  Create FFT setup
        // __Log2nは log2(64) = 6 より、6 を指定
        
        
        let fftLevel = 64 //fftのポイント数を指定
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

        var mag = [Int]() //周波数の強度を格納
        var xAxis = [Double]() //x軸の対応関係
        
        for n in 0..<fftLevel/2 {
            let rel = r[n]
            let img = i[n]
            let magSub = sqrtf(rel * rel + img * img)
            
            mag.append(Int(magSub))                                //配列に格納
            xAxis.append(Double(numSamples) / 64 * Double(n))
            
            let log = "[%02d]: Mag: %5.2f, Rel: %5.2f, Img: %5.2f"
            print(String(format: log, n, magSub, rel, img))
        }
        

        
        var rect = view.bounds
        //表示位置
        rect.origin.y += 50
        rect.size.height -= 200
        let barChartView = BarChartView(frame: rect) //棒グラフの宣言
        
        //xとyの値の格納
        var entry = [BarChartDataEntry]()
        for index in 0..<fftLevel/2 {
            entry.append(BarChartDataEntry(x: Double(xAxis[index]), y: Double(mag[index])))
        }
        
        //datasetとして書き出す
        let set = [
            BarChartDataSet(values: entry, label: "Data")
        ]
        
        
        barChartView.data = BarChartData(dataSets: set)
        view.addSubview(barChartView)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

