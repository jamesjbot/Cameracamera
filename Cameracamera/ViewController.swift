//
//  ViewController.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/8/17.
//  Copyright © 2017 James Jongs. All rights reserved.
//

import UIKit
import AVFoundation


// MARK: -

@IBDesignable
class ViewController: UIViewController {

    // MARK: Constants

    private let throttleTime: Double = 0.2

    // MARK: Variables

    private var lastDrawnViews = [UIView]()

    fileprivate var viewModel: ViewModelInteractions?

    private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?

    // MARK: IBOutlets

    @IBOutlet weak var previewView: UIView!

    @IBInspectable @IBOutlet weak var onTapTakePhoto: UIButton!

    @IBOutlet var mainView: UIView!


    // MARK: IBAction

    @IBAction func takePhoto(_ sender: Any) {
        viewModel?.savePhoto()
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
        _ = viewModel?.metadataCodeObjects.throttle(seconds: throttleTime).observeNext {

            [unowned self] event in

            guard let newViews = self.viewModel?.lastOutlineViews.array else {
                print("Returned because of nil value in newViews")
                return
            }

            self.detachOld(outlines: self.lastDrawnViews)
            self.lastDrawnViews.removeAll()
            self.attach(these: newViews, to: self.view)
            self.lastDrawnViews = newViews
        }
    }


    func initializePreviewLayer() {

        if let preview = viewModel?.getCaptureVideoPreviewLayer() {
            _ = attachPreview(preview: preview)
        }
    }


    // Add the video preview layer as a sublayer to IBOutlet previewView
    func attachPreview(preview videoPreview: AVCaptureVideoPreviewLayer) -> UIView {

        print("You're attachingPreview")
        captureVideoPreviewLayer = videoPreview

        guard captureVideoPreviewLayer != nil else {
            return UIView()
        }

        // Set previewLayer to our viewcontroller bounds
        captureVideoPreviewLayer?.frame = self.mainView.layer.bounds

        DispatchQueue.main.async {
            self.previewView.layer.addSublayer(self.captureVideoPreviewLayer!)
        }

        return previewView
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

    fileprivate func attach(these outlines: [UIView], to view: UIView) {
        
        DispatchQueue.main.async {
            let _ = outlines.map { view.addSubview($0) }
        }
    }

    fileprivate func detachOld(outlines: [UIView]) {

        DispatchQueue.main.async {
            _ = outlines.map { $0.removeFromSuperview() }
        }
    }

    class DependencyInjector {

        static func attachViewModel(to viewcontroller: ViewController) -> ViewController {

            let model = Model()
            let viewModel = ViewModel(model)
            viewcontroller.viewModel = viewModel
            return viewcontroller
        }
    }

}





















