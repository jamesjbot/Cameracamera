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

enum ModelError: Error {
    case CaptureOutputNotOpen
    case PhotoSampleBufferNil
    case InitializeCaptureInputError
    case JPEGPhotoRepresentationError
}

// MARK: -

struct MetaDataObjectAndPayload {

    var metaDataObject: AVMetadataObject
    var payload: String
}


/// This model create the Apple framework links to the AVFoundation for receving and preprocessing 
/// Metadata.

class Model: NSObject {

    // MARK: -
    // MARK: Constants

    fileprivate let SCALE = CGFloat(1.0)

    // MARK: -
    // MARK: Variables

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

        // Attach input to capture seesion
        captureSession?.addInput(captureInput)

        videoPreviewLayer = makeVideoPreviewViewLayer()

        initializeCaptureOutputs()

        attachOutputsToCaptureSession()

        initializeMetaDataCaptureProperties()

        // Start capture session
        captureSession?.startRunning()
    }


    /// Initialize the capture device and connect it to the capture input
    func initializeCaptureInputs() {

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
    func initializeMetaDataCaptureProperties() {

        // Specify the types of metadata you want to identify
        captureMetaDataOutput?.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode]
        // For future implementatin here are the other codes we can scan for [,AVMetadataObjectTypeFace,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypePDF417Code]

        // Set youself to capture metadata.
        captureMetaDataOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
    }


    /// This method sets up all the outputs.
    func initializeCaptureOutputs() {

        // Create a photo capture output for our capture session
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput?.isHighResolutionCaptureEnabled = true

        // Create a metadata capture output for our capture session
        captureMetaDataOutput = AVCaptureMetadataOutput()
    }


    ///
    func attachOutputsToCaptureSession() {

        // Attach output to capture session
        captureSession?.addOutput(capturePhotoOutput)
        captureSession?.addOutput(captureMetaDataOutput)
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
        let capturedImage = UIImage.init(data: imageData, scale: SCALE)
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
    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputMetadataObjects metadataObjects: [Any]!,
                       from connection: AVCaptureConnection!) {
        
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

            let dataAndPayload = MetaDataObjectAndPayload(metaDataObject: convertedObject,
                                                          payload: metadataObject.stringValue)

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
    internal func savePhoto(_ completion: ((Bool)->())? = nil ) {

        // Make sure our output is open
        guard let capturePhotoOutput = self.capturePhotoOutput else {
            currentError = ModelError.CaptureOutputNotOpen
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
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        
    }
}

