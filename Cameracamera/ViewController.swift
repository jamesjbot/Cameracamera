//
//  ViewController.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/8/17.
//  Copyright © 2017 James Jongsurasithiwat. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyBeaver

// MARK: - ViewController

/// The general architecture is once the view/viewcontroller, viewmodel, and model are hooked up by
/// reactive binding thru two variables (one in viewmodel, and one in the model).
/// All metadata objects detected by the model will be passed up to the viewmodel, where 
/// the viewmodel will monitor which metadata objects are currently on screen.
/// The viewmodel will then pass these views (via reactive binding) to the view/viewcontroller for presentation.
/// The outline objects have a "time to live" after the outline's time is up,
/// the outline will remove itself from the super view and from the viewmodel.

@IBDesignable
class ViewController: UIViewController {

    // MARK: Constants


    // MARK: Variables

    fileprivate var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?

    internal var lastDrawnViews = [UIView]()

    fileprivate var viewModel: ViewModelInteractions?


    // MARK: IBOutlets

    @IBOutlet weak var feedbackImageView: UIImageView!

    @IBInspectable @IBOutlet weak var onTapTakePhoto: UIButton!

    @IBOutlet weak var outlineStoryBoardView: UIView!

    @IBOutlet weak var previewView: UIView!

    @IBOutlet weak var saveQRCodesLabel: UILabel!

    @IBOutlet weak var saveQRCodesToggle: UISwitch!

    @IBOutlet weak var takePhoto: UIButton!


    // MARK: IBAction

    @IBAction func takePhoto(_ sender: Any) {
        if saveQRCodesToggle.isOn {
            takePhotoWithQRCodesOverlaid()
        }
        else {
            viewModel?.savePhoto(delegate: nil, completion: nil)
        }
    }


    // MARK: Functions

    // MARK: Life Cycle Functions

    override func viewDidLoad() {

        // Setup the structure
        _ = DependencyInjector.attachViewModelInteractions(to: self)

        // Setup the video preview
        initializePreviewLayer()

        feedbackImageView.contentMode = .scaleAspectFill

        super.viewDidLoad()

    }


    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // Format size of UIButton
        onTapTakePhoto.sizeToFit()

        // Binding to the view model
        bindViewModel()
    }


    override func viewWillLayoutSubviews() {

        super.viewWillLayoutSubviews()

        // Refills the frame up to the fullsize.
        captureVideoPreviewLayer?.frame = self.view.bounds

        // Verify we have a connection before accessing it
        guard let connection = captureVideoPreviewLayer?.connection else {
            return
        }

        let orientation: UIDeviceOrientation = UIDevice.current.orientation

        /// Rear facing camera flips the orientaion
        switch orientation {
        case .landscapeLeft:
            connection.videoOrientation = .landscapeRight
        case .landscapeRight:
            connection.videoOrientation = .landscapeLeft
        case .portrait:
            connection.videoOrientation = .portrait
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        default:
            break
        }
    }


    // MARK: Normal methods

    private func bindViewModel() {

        // When a change is detected on metadata objects, remove the old objects 
        // and draw the new objects on the view.

        _ = viewModel?.lastOutlineViews.observeNext {

            [unowned self] event in
            SwiftyBeaver.info("\nViewController received \(event.count) new views")
            let newViews = event.dataSource

            // Ignore when there are no new views.
            guard newViews.count > 0 else {
                return
            }

            self.attach(theseOutlines: newViews, to: self.outlineStoryBoardView)
        }
    }


    private func initializePreviewLayer() {

        _ = viewModel?.attachAVCapturePreview(toReceiver: self)
    }

    
    /**
     Takes a pictures with QRCodes overlaid and saves it to the photo album roll
     */
    private func takePhotoWithQRCodesOverlaid() {

        viewModel?.savePhoto(delegate: self) {
            success, image in
            guard success else {
                return
            }
        }
    }
}


// MARK: - AlertWindowDisplaying

extension ViewController: AlertWindowDisplaying {

    func display(error: String) -> Bool {
        DispatchQueue.main.async {
            self.displayAlertWindow(title: "Error", msg: error)
        }
        return true
    }
}


// MARK: - Attaching outlines to view
extension ViewController {

    fileprivate func attach(theseOutlines outlines: [UIView], to superView: UIView) {
        DispatchQueue.main.async {
            let _ = outlines.map { superView.addSubview($0) }
        }
    }
}


// MARK: - AVCapturePhotoCaptureDelegate

extension ViewController: AVCapturePhotoCaptureDelegate {

    /// This method receives photo captured by "Take Photo" button.
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

        let currentError: Error?

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

        self.feedbackImageView.image = capturedImage
        self.feedbackImageView.isHidden = false

        // Hide UI elements
        self.saveQRCodesToggle.isHidden = true
        self.saveQRCodesLabel.isHidden = true

        // Creates a UIImage

        // Render view to an image
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.isOpaque, Constants.fullPixelSize )

        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)

        let photo : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // Reveal onscreen ui elements
        self.saveQRCodesToggle.isHidden = false
        self.saveQRCodesLabel.isHidden = false
        self.takePhoto.isHidden = false
        self.feedbackImageView.isHidden = true

        // Save image to photoalbum.
        // The user will be notified with a camera picture taking sound this is standard.
        UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
        if #available(iOS 9.0, *) {
            AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1108), nil)
        } else {
            AudioServicesPlaySystemSound(1108)
        }
    }
}


// MARK: - AVCapturePreviewReceiver
extension ViewController: AVCapturePreviewReceiver {

    // Add the video preview layer as a sublayer to IBOutlet previewView
    func attachToSelf(preview videoPreview: AVCaptureVideoPreviewLayer) -> AVCapturePreviewReceiver? {

        captureVideoPreviewLayer = videoPreview

        guard captureVideoPreviewLayer != nil else {
            return nil
        }

        // Set previewLayer to our viewcontroller bounds
        captureVideoPreviewLayer?.frame = previewView.layer.bounds

        // Attach the captureVideoPreview to our previewView
        previewView.layer.addSublayer(captureVideoPreviewLayer!)
        return self
    }
}


// MARK: - Helper Class

class DependencyInjector {

    static func attachViewModelInteractions(to viewcontroller: ViewController, viewModel: ViewModelInteractions? = nil) -> ViewController {

        if viewModel == nil {
            let model = Model()
            viewcontroller.viewModel = ViewModel(model)
        } else {
            viewcontroller.viewModel = viewModel
        }

        return viewcontroller
    }
}




















