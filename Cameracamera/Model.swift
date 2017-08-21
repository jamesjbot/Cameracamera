//
//  Model.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/9/17.
//  Copyright © 2017 James Jongs. All rights reserved.
//

import UIKit
import AVFoundation
import Bond

// MARK: -

struct Constants {
    static let offset = CGFloat(20)
    static let scaling = CGFloat(1.02)
    static let ourBorderColor = UIColor.red.cgColor
    static let ourBorderWidth = CGFloat(3.0)
}

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

// MARK: -

class DetectedObjectOutline {

    var uiViewRepresentation: UIView?

    init(metaDataObject: MetaDataObjectAndPayload) {

            let bounds = metaDataObject.metaDataObject.bounds
            self.uiViewRepresentation = UIView(frame: CGRect(x: (bounds.minX),
                                                        y: ((bounds.minY) + Constants.offset),
                                                        width: ((bounds.width) * Constants.scaling),
                                                        height: ((bounds.height) * Constants.scaling))
            )
            self.uiViewRepresentation?.layer.borderColor = Constants.ourBorderColor
            self.uiViewRepresentation?.layer.borderWidth = Constants.ourBorderWidth

            // Displays the type of code
            let typeLabel = UILabel()
            typeLabel.attributedText = NSAttributedString(string: metaDataObject.metaDataObject.type!)
            typeLabel.textColor = UIColor.green
            typeLabel.backgroundColor = UIColor.gray
            typeLabel.adjustsFontSizeToFitWidth = true

            // Displays the encoded information
            let contentLabel = UILabel()
            contentLabel.attributedText = (NSAttributedString(string: metaDataObject.payload))
            contentLabel.textColor = UIColor.cyan
            contentLabel.backgroundColor = UIColor.gray
            contentLabel.adjustsFontSizeToFitWidth = true

            // Organize their presentation
            let stackView = UIStackView(arrangedSubviews: [typeLabel,contentLabel])
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.distribution = .equalSpacing
            if let bounds = self.uiViewRepresentation?.bounds {
                stackView.frame = bounds
            }

            // Attach them to the view
            self.uiViewRepresentation?.addSubview(stackView)
    }
}


class Model: NSObject, ModelInteractions {

    internal var currentError: ModelError? = nil

    // Holds a reference to the videoPreviewLayer
    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    // Metadata Objects from capture
    internal var metadataCodeObjects = MutableObservableArray<AVMetadataMachineReadableCodeObject>([])

    // Helps transfer data between one or more device inputs
    private var captureSession: AVCaptureSession?

    // Output for photo
    private var capturePhotoOutput: AVCapturePhotoOutput?
    private var captureMetaDataOutput: AVCaptureMetadataOutput?

    // Inputs for photo
    var captureDevice: AVCaptureDevice?
    var captureInput: AVCaptureInput?

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


    func initializeCaptureInputs() {

        // Create a capture device
        captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

        // Create the intermediary between input device and capture device.
        do {
            captureInput = try AVCaptureDeviceInput(device: captureDevice)
        }
        catch let error {
            currentError = ModelError.InitializeCaptureInputError
        }
    }


    /// This method sets the types of meta data you want to scan for.
    func initializeMetaDataCaptureProperties() {

        // Specify the types of metadata you want to identify
        captureMetaDataOutput?.metadataObjectTypes = [AVMetadataObjectTypeQRCode]//[AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeFace,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypePDF417Code]

        // Set youself to capture metadata.
        captureMetaDataOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
    }


    /// Put the all capture ourput initialization here
    func initializeCaptureOutputs() {

        // Create a capture output for our capture session
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput?.isHighResolutionCaptureEnabled = true

        // Initialize a metadataoutput and set it to capture from the session.
        captureMetaDataOutput = AVCaptureMetadataOutput()
    }


    func attachOutputsToCaptureSession() {

        // Attach output to capture session
        captureSession?.addOutput(capturePhotoOutput)
        captureSession?.addOutput(captureMetaDataOutput)
    }


    private func makeVideoPreviewViewLayer() -> AVCaptureVideoPreviewLayer? {

        // Configure previewView
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        // Configure layer to resize while maintaining aspect ratio
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill

        return videoPreviewLayer
    }


    func savePhoto() {

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


extension Model: AVCapturePhotoCaptureDelegate {

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
        let capturedImage = UIImage.init(data: imageData, scale: 1.0)
        if let image = capturedImage {
            // Save image to photoalbum.
            // FIXME: Add targets to notify the UI that we saved an image
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

        }
    }
}


extension Model: AVCaptureMetadataOutputObjectsDelegate {

    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputMetadataObjects metadataObjects: [Any]!,
                       from connection: AVCaptureConnection!) {

        // Clear out the local variables containing the Meta data Codes
        self.metadataCodeObjects.removeAll()

        // Attach the new meta data codes to the array
        for metadataObject in metadataObjects {

            guard let metadataObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
                continue
            }
            self.metadataCodeObjects.append(metadataObject)
        }
    }
}


extension Model {

    // This exposes the AVCaptureVideoPreviewLayer to the ViewController.
    internal func getCaptureVideoPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return videoPreviewLayer
    }

}

