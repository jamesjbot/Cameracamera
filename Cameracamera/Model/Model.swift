//
//  Model.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/9/17.
//  Copyright © 2017 James Jongsurasithiwat. All rights reserved.
//

import UIKit
import AVFoundation
import Bond


// MARK: -

struct MetaDataObjectAndPayload {

    //var metaDataObject: AVMetadataObject
    var bounds: CGRect
    var payload: String
    var type: String
}


/// This model create the Apple framework links to the AVFoundation for receving and preprocessing 
/// Metadata.

class Model: NSObject {

    // MARK: -
    // MARK: Constants

    // MARK: -
    // MARK: Variables

    fileprivate var completionHandlerForSavedPhoto: ((Bool,Error?)->())? = nil

    internal var currentError: ModelError? = nil

    // Holds a reference to the videoPreviewLayer
    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    // Metadata Objects from capture
    internal var metadataCodeObjects = MutableObservableArray<MetaDataObjectAndPayload>([])

    // Helps transfer data between one or more device inputs
    private var captureSession: AVCaptureSession?

    // Output for photo
    fileprivate var capturePhotoOutput: AVCapturePhotoOutput?
    private var captureMetaDataOutput: AVCaptureMetadataOutput?

    // Inputs for photo
    private var captureDevice: AVCaptureDevice?
    private var captureInput: AVCaptureInput?

    // MARK: Functions

    override init() {

        super.init()

        initialize()
    }


    /// Setup the AVFoundtaion objects needed to capture images
    func initialize() {

        initializeCaptureInputs()

        // Initialize our captureSession
        captureSession = AVCaptureSession()

        attachInputToCaptureSession()

        videoPreviewLayer = makeVideoPreviewViewLayer()

        initializeCaptureOutputs()

        attachOutputsToCaptureSession()

        initializeMetaDataCaptureProperties()

        // Start capture session
        captureSession?.startRunning()
    }


    /// Initialize the capture device and connect it to the capture input
    private func initializeCaptureInputs() {

        // Create a capture device
        captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

        // Create the intermediary between input device and capture device.
        do {
            captureInput = try AVCaptureDeviceInput(device: captureDevice)
        }
        catch _ {
            currentError = ModelError.InitializeCaptureInputError
        }
    }


    /// This method sets the types of meta data you want to scan for.
    private func initializeMetaDataCaptureProperties() {

        for type in AcceptableMetadataTypes.desiredTypes {
            if (captureMetaDataOutput?.availableMetadataObjectTypes.contains(where: {($0 as? String) == type})) ?? false {
                captureMetaDataOutput?.metadataObjectTypes.append(type)
            }
        }

        // Set yourself to capture metadata.
        captureMetaDataOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
    }


    /// This method sets up all the outputs.
    private func initializeCaptureOutputs() {

        // Create a photo capture output for our capture session
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput?.isHighResolutionCaptureEnabled = true

        // Create a metadata capture output for our capture session
        captureMetaDataOutput = AVCaptureMetadataOutput()
    }


    private func attachInputToCaptureSession() {
        // Attach input to capture seesion
        guard let captureInput = captureInput else {
            return
        }
        captureSession?.addInput(captureInput)
    }



    ///
    private func attachOutputsToCaptureSession() {

        // Attach output to capture session
        if let capturePhotoOutput = capturePhotoOutput {
            captureSession?.addOutput(capturePhotoOutput)
        }
        if let captureMetaDataOutput = captureMetaDataOutput {
            captureSession?.addOutput(captureMetaDataOutput)
        }
    }


    /// This will create a preview layer for the viewcontroller.
    private func makeVideoPreviewViewLayer() -> AVCaptureVideoPreviewLayer? {

        // Configure previewView
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        // Configure layer to resize while maintaining aspect ratio
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill

        return videoPreviewLayer
    }
}


// MARK: - AVCapturePhotoCaptureDelegate

extension Model: AVCapturePhotoCaptureDelegate {

    /// This method receives photo captured by "Take Photo" button.
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

        // Make sure there were no errors and the buffer was populated
        guard error == nil, let photoSampleBuffer = photoSampleBuffer else {
            currentError = ModelError.PhotoSampleBufferNil
            return
        }

        // Convert photo buffer to jpeg
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            currentError = ModelError.JPEGPhotoRepresentationError
            return
        }

        // Create a UIImage with our data
        let capturedImage = UIImage.init(data: imageData, scale: Constants.avCaptureScale)
        if let image = capturedImage {
            // Save image to photoalbum.
            // The user will be notified with a camera picture taking sound this is standard.
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension Model: AVCaptureMetadataOutputObjectsDelegate {

    /// This method captures metadata objects when they are detected from the Apple AVFoundation framework.
    func captureOutput(_ captureOutput: AVCaptureOutput,
                       didOutputMetadataObjects metadataObjects: [Any],
                       from connection: AVCaptureConnection) {
        
        var accumulatedAVMetadata = [MetaDataObjectAndPayload]()

        // Convert AVMetadataMachineReadableCodeObjects into AVMetaDataObect and a string
        for metadataObject in metadataObjects {

            guard let metadataObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
                continue
            }

            // Convert from VideoPreview coordinates to UIKit coordinates
            guard let convertedObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject) else {
                continue
            }

            let dataAndPayload = MetaDataObjectAndPayload(bounds: convertedObject.bounds,
                                                          payload: metadataObject.stringValue,
                                                          type: convertedObject.type)

            accumulatedAVMetadata.append(dataAndPayload)
        }

        // Attach the new meta data codes to the observable array
        metadataCodeObjects.replace(with: accumulatedAVMetadata)
    }
}


// MARK: -
// MARK: AVCapturePreviewProvider Protocol
extension Model: AVCapturePreviewProvider {

    /**
     Attaches an AVCapture preview layer to whatever would like it

     - Returns: Returns a reference to the PreviewLayer owned by the model
     */
    func attachAVCapturePreview(toReceiver: AVCapturePreviewReceiver) -> AVCapturePreviewReceiver? {
        
        if let videoPreview = videoPreviewLayer {
            return toReceiver.attachToSelf(preview: videoPreview)
        }
        return nil

    }
}


// MARK: -
// MARK: Protocol Methods

extension Model: ModelInteractions {

    /// This will call the AVFoundation framework to take a picture.
    internal func savePhoto(delegate viewcontrollerNeedsAnImage: AVCapturePhotoCaptureDelegate?,
                            completion: ((Bool,Error?)->())? = nil ) {

        completionHandlerForSavedPhoto = completion

        // Take a picture without QRCodes.

        let videoOrientation = determineVideoOrientation()

        // Set the video orientation on the input
        if let connection: AVCaptureConnection = capturePhotoOutput?.connections.first as? AVCaptureConnection {
            connection.videoOrientation = videoOrientation
        }

        // Make sure our output is open
        guard let capturePhotoOutput = capturePhotoOutput else {
            completion?(false,ModelError.CaptureOutputNotOpen)
            return
        }

        // Create capture settings
        let photoSettings = AVCapturePhotoSettings()

        // Set the capture settings
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true

        // Set flash depending on device, Ipad Air 2 currently
        photoSettings.flashMode = .off

        // Call the capture photo and register to receive captured photo
        if viewcontrollerNeedsAnImage != nil {
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: viewcontrollerNeedsAnImage!)
        } else {
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }


    private func determineVideoOrientation() -> AVCaptureVideoOrientation {

        let orientation = UIDevice.current.orientation
        var videoOrientation: AVCaptureVideoOrientation?
        switch orientation {
        case .landscapeLeft:
            videoOrientation = AVCaptureVideoOrientation.landscapeRight
        case .landscapeRight:
            videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        case .portrait:
            videoOrientation = AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown:
            videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            videoOrientation = AVCaptureVideoOrientation.portrait
        }
        return videoOrientation!

    }

}

