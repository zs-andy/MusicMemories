//
//  File.swift
//  Music Memories
//
//  Created by Andy on 2025/2/23.
//

import Foundation
import CoreML
import CoreGraphics
import UIKit

func resizeCGImageTo416x416(_ image: CGImage) -> CGImage? {
    let size = CGSize(width: 416, height: 416)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    guard let context = CGContext(data: nil,width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 4 * Int(size.width), space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
        return nil
    }
    context.draw(image, in: CGRect(origin: .zero, size: size))
    return context.makeImage()
}

func findSubject(inputImage: UIImage?, detector: YOLOv3TinyFP16) -> Int{
    if let image = inputImage, let CG = image.cgImage{
        if let cgImage = resizeCGImageTo416x416(CG) {
            let input = try! YOLOv3TinyFP16Input(imageWith: cgImage, iouThreshold: 0.5, confidenceThreshold: 0.4)
            do {
                let output = try detector.prediction(input: input)
                let confidence = output.confidence
                let coordinates = output.coordinates
                if confidence.count > 0 && coordinates.count > 0{
                    var maxBoxSize: Double = -1.0
                    var maxBoxIndex: Int = -1
                    for i in 0..<(coordinates.count/4) {
                        let w = coordinates[i * 4 + 2].doubleValue
                        let h = coordinates[i * 4 + 3].doubleValue
                        let boxSize = w * h
                        if boxSize > maxBoxSize {
                            maxBoxSize = boxSize
                            maxBoxIndex = i
                        }
                    }
                    var maxConfidence: Double = -1.0
                    var maxConfidenceIndex: Int = -1
                    if maxBoxIndex != -1{
                        for i in 0..<80 {
                            let conf = confidence[maxBoxIndex * 80 + i].doubleValue
                            if conf > maxConfidence {
                                maxConfidence = conf
                                maxConfidenceIndex = i
                            }
                        }
                    }
                    return maxConfidenceIndex
                    print("\(maxConfidence) \(maxConfidenceIndex)")
                }else{
                    print("没有识别到任何物体")
                }
            } catch {
                print("Prediction failed: \(error)")
            }
        }
    }
    return -1
}
