//
//  File.swift
//  Music Memories
//
//  Created by Andy on 2025/2/23.
//

import Foundation
import CoreML

public class YOLOv3TinyFP16Input : MLFeatureProvider {

    /// 416x416 RGB image as color (kCVPixelFormatType_32BGRA) image buffer, 416 pixels wide by 416 pixels high
    var image: CVPixelBuffer

    /// This defines the radius of suppression. as optional double value
    var iouThreshold: Double? = nil

    /// Remove bounding boxes below this threshold (confidences should be nonnegative). as optional double value
    var confidenceThreshold: Double? = nil

    public var featureNames: Set<String> { ["image", "iouThreshold", "confidenceThreshold"] }

    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "image" {
            return MLFeatureValue(pixelBuffer: image)
        }
        if featureName == "iouThreshold" {
            return iouThreshold == nil ? nil : MLFeatureValue(double: iouThreshold!)
        }
        if featureName == "confidenceThreshold" {
            return confidenceThreshold == nil ? nil : MLFeatureValue(double: confidenceThreshold!)
        }
        return nil
    }

    init(image: CVPixelBuffer, iouThreshold: Double? = nil, confidenceThreshold: Double? = nil) {
        self.image = image
        self.iouThreshold = iouThreshold
        self.confidenceThreshold = confidenceThreshold
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    convenience init(imageWith image: CGImage, iouThreshold: Double? = nil, confidenceThreshold: Double? = nil) throws {
        self.init(image: try MLFeatureValue(cgImage: image, pixelsWide: 416, pixelsHigh: 416, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    convenience init(imageAt image: URL, iouThreshold: Double? = nil, confidenceThreshold: Double? = nil) throws {
        self.init(image: try MLFeatureValue(imageAt: image, pixelsWide: 416, pixelsHigh: 416, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    func setImage(with image: CGImage) throws  {
        self.image = try MLFeatureValue(cgImage: image, pixelsWide: 416, pixelsHigh: 416, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    func setImage(with image: URL) throws  {
        self.image = try MLFeatureValue(imageAt: image, pixelsWide: 416, pixelsHigh: 416, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

}


/// Model Prediction Output Type
@available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, visionOS 1.0, *)
public class YOLOv3TinyFP16Output : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// Confidence derived for each of the bounding boxes.  as multidimensional array of doubles
    var confidence: MLMultiArray {
        provider.featureValue(for: "confidence")!.multiArrayValue!
    }

    /// Confidence derived for each of the bounding boxes.  as multidimensional array of doubles
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var confidenceShapedArray: MLShapedArray<Double> {
        MLShapedArray<Double>(confidence)
    }

    /// Normalised coordiantes (relative to the image size) for each of the bounding boxes (x,y,w,h).  as multidimensional array of doubles
    var coordinates: MLMultiArray {
        provider.featureValue(for: "coordinates")!.multiArrayValue!
    }

    /// Normalised coordiantes (relative to the image size) for each of the bounding boxes (x,y,w,h).  as multidimensional array of doubles
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var coordinatesShapedArray: MLShapedArray<Double> {
        MLShapedArray<Double>(coordinates)
    }

    public var featureNames: Set<String> {
        provider.featureNames
    }

    public func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }

    init(confidence: MLMultiArray, coordinates: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["confidence" : MLFeatureValue(multiArray: confidence), "coordinates" : MLFeatureValue(multiArray: coordinates)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, visionOS 1.0, *)
public class YOLOv3TinyFP16 {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
       let bundle = Bundle(for: self)
       let mlModelUrl = bundle.url(forResource: "MLModel/YOLOv3TinyFP16", withExtension:"mlmodel")!
        return try! MLModel.compileModel(at: mlModelUrl)
   }

    /**
        Construct YOLOv3TinyFP16 instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of YOLOv3TinyFP16.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `YOLOv3TinyFP16.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct YOLOv3TinyFP16 instance by automatically loading the model from the app's bundle.
    */
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct YOLOv3TinyFP16 instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct YOLOv3TinyFP16 instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<YOLOv3TinyFP16, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct YOLOv3TinyFP16 instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> YOLOv3TinyFP16 {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct YOLOv3TinyFP16 instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<YOLOv3TinyFP16, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(YOLOv3TinyFP16(model: model)))
            }
        }
    }

    /**
        Construct YOLOv3TinyFP16 instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> YOLOv3TinyFP16 {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return YOLOv3TinyFP16(model: model)
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as YOLOv3TinyFP16Input

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as YOLOv3TinyFP16Output
    */
    func prediction(input: YOLOv3TinyFP16Input) throws -> YOLOv3TinyFP16Output {
        try prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as YOLOv3TinyFP16Input
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as YOLOv3TinyFP16Output
    */
    func prediction(input: YOLOv3TinyFP16Input, options: MLPredictionOptions) throws -> YOLOv3TinyFP16Output {
        let outFeatures = try model.prediction(from: input, options: options)
        return YOLOv3TinyFP16Output(features: outFeatures)
    }

    /**
        Make an asynchronous prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as YOLOv3TinyFP16Input
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as YOLOv3TinyFP16Output
    */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: YOLOv3TinyFP16Input, options: MLPredictionOptions = MLPredictionOptions()) async throws -> YOLOv3TinyFP16Output {
        let outFeatures = try await model.prediction(from: input, options: options)
        return YOLOv3TinyFP16Output(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        It uses the default function if the model has multiple functions.

        - parameters:
            - image: 416x416 RGB image as color (kCVPixelFormatType_32BGRA) image buffer, 416 pixels wide by 416 pixels high
            - iouThreshold: This defines the radius of suppression. as optional double value
            - confidenceThreshold: Remove bounding boxes below this threshold (confidences should be nonnegative). as optional double value

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as YOLOv3TinyFP16Output
    */
    func prediction(image: CVPixelBuffer, iouThreshold: Double?, confidenceThreshold: Double?) throws -> YOLOv3TinyFP16Output {
        let input_ = YOLOv3TinyFP16Input(image: image, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)
        return try prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - inputs: the inputs to the prediction as [YOLOv3TinyFP16Input]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [YOLOv3TinyFP16Output]
    */
    func predictions(inputs: [YOLOv3TinyFP16Input], options: MLPredictionOptions = MLPredictionOptions()) throws -> [YOLOv3TinyFP16Output] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [YOLOv3TinyFP16Output] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  YOLOv3TinyFP16Output(features: outProvider)
            results.append(result)
        }
        return results
    }
}
