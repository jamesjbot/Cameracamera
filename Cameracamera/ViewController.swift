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

// MARK: -

/// This general architecture is once the view/viewcontroller, viewmodel, and model are hooked up by
/// reactive binding thru two variables (one in viewmodel, and one in the model).
/// All metadata objects detected by the model will be passed up to the viewmodel, where 
/// the viewmodel will monitor which metadata objects are currently on screen.
/// The viewmodel will then pass these views to the view/viewcontroller for presentation.
/// The outline objects have a "time to live" after the outline's time is up,
/// the outline will remove itself from the super view and from the viewmodel.

@IBDesignable
class ViewController: UIViewController {

    // MARK: Constants

    // MARK: Variables

    public var lastDrawnViews = [UIView]()

    fileprivate var viewModel: ViewModelInteractions?

    fileprivate var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?

    // MARK: IBOutlets

    @IBOutlet weak var previewView: UIView!

    @IBInspectable @IBOutlet weak var onTapTakePhoto: UIButton!

    @IBOutlet var mainView: UIView!


    // MARK: IBAction

    @IBAction func takePhoto(_ sender: Any) {
        viewModel?.savePhoto(nil)
    }


    // MARK: Functions

    // MARK: Life Cycle Functions

    override func viewDidLoad() {

        // Setup the structure
        _ = DependencyInjector.attachViewModelInteractions(to: self)

        // Setup the video preview
        initializePreviewLayer()

        super.viewDidLoad()

    }


    override func viewWillAppear(_ animated: Bool) {

        // Format size of UIButton
        onTapTakePhoto.sizeToFit()

        super.viewWillAppear(animated)

        // Binding to the view model
        bindViewModel()
    }


    func bindViewModel() {

        // When a change is detected on metadata objects, remove the old objects 
        // and draw the new objects on the view.

        _ = viewModel?.lastOutlineViews.observeNext {

            [unowned self] event in
            SwiftyBeaver.info("\nViewController received \(event.count) new views")
            let newViews = event.dataSource

            guard newViews.count > 0 else {
                return
            }
            self.attach(these: newViews, to: self.view.window!)
        }
    }


    func initializePreviewLayer() {

        _ = viewModel?.attachAVCapturePreview(toReceiver: self)
    }
}


extension ViewController: AlertWindowDisplaying {

    func display(error: String) -> Bool {
        DispatchQueue.main.async {
            self.displayAlertWindow(title: "Error", msg: error)
        }
        return true
    }
}


extension ViewController {

    fileprivate func attach(these outlines: [UIView], to superView: UIView) {
        DispatchQueue.main.async {
            let _ = outlines.map { superView.addSubview($0) }
        }
    }
}

extension ViewController: AVCapturePreviewReceiver {

    // Add the video preview layer as a sublayer to IBOutlet previewView
    func attachToSelf(preview videoPreview: AVCaptureVideoPreviewLayer) -> AVCapturePreviewReceiver? {

        captureVideoPreviewLayer = videoPreview

        guard captureVideoPreviewLayer != nil else {
            return nil
        }

        // Set previewLayer to our viewcontroller bounds
        captureVideoPreviewLayer?.frame = mainView.layer.bounds

        // Attach the captureVideoPreview to our previewView
        previewView.layer.addSublayer(captureVideoPreviewLayer!)
        return self
    }
}


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




















