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

@IBDesignable
class ViewController: UIViewController {

    // MARK: Constants

    private let throttleTime: Double = 0.5

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
        _ = DependencyInjector.attachViewModel(to: self)

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

        if let preview = viewModel?.getCaptureVideoPreviewLayer() {
            _ = attachPreview(preview: preview)
        }
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


    // Add the video preview layer as a sublayer to IBOutlet previewView
    fileprivate func attachPreview(preview videoPreview: AVCaptureVideoPreviewLayer) -> UIView {

        captureVideoPreviewLayer = videoPreview

        guard captureVideoPreviewLayer != nil else {
            return UIView()
        }

        // Set previewLayer to our viewcontroller bounds
        captureVideoPreviewLayer?.frame = self.mainView.layer.bounds

        // Attach the captureVideoPreview to our previewView
        DispatchQueue.main.async {
            self.previewView.layer.addSublayer(self.captureVideoPreviewLayer!)
        }

        return previewView
    }
}


class DependencyInjector {

    static func attachViewModel(to viewcontroller: ViewController, viewModel: ViewModelInteractions? = nil) -> ViewController {

        if viewModel == nil {
            let model = Model()
            viewcontroller.viewModel = ViewModel(model)
        } else {
            viewcontroller.viewModel = viewModel
        }

        return viewcontroller
    }
}




















