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

    private let throttleTime: Double = 0.5

    // MARK: Variables

    public var lastDrawnViews = [UIView]()

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

        _ = viewModel?.lastOutlineViews.observeNext {

            [unowned self] event in

            //print("View controller intercepted View model with \(event.dataSource.count) entries")
//            print("The change event:\(event.change)")
//            print("The change kind: \(event.kind)")
//            print("datasource:\(event.dataSource)")
//            print("source: \(event.source)")
            //let newViews = event.dataSource.array
            print("\nViewController Incoming array count\(event.count)")
            print("Viewcontroller incoming array: \(event)")
            let newViews = event.dataSource
            //            else {
//                print("Returned because of nil value in newViews")
//                return
//            }

            if event.count > 0 {
                print("ViewController Found something")
            } else {
                print("ViewController Attaching no views")
            }

            self.detachOld(outlines: self.lastDrawnViews)
            self.lastDrawnViews.removeAll()
            self.lastDrawnViews = newViews
            guard newViews.count > 0 else {
                return
            }
            self.attach(these: newViews, to: self.view.window!)
            print("Exit ViewController\n")
        }
    }


    func initializePreviewLayer() {

        if let preview = viewModel?.getCaptureVideoPreviewLayer() {
            _ = attachPreview(preview: preview)
        }
    }


    // Add the video preview layer as a sublayer to IBOutlet previewView
    func attachPreview(preview videoPreview: AVCaptureVideoPreviewLayer) -> UIView {

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
        for view in outlines {
            print("Viewcontroller attach Space")
            print("Viewcontroller frame \(view.frame)")
        }
        DispatchQueue.main.async {
            print("Attached new views")
//            for view in outlines {
//                print("Bounds: \(view.bounds)")
//            }
            let _ = outlines.map { superView.addSubview($0) }
        }
    }

    fileprivate func detachOld(outlines: [UIView]) {

        DispatchQueue.main.async {
            print("View controller Remove new views")
            _ = outlines.map { $0.removeFromSuperview() }
        }
    }
}


class DependencyInjector {

    static func attachViewModel(to viewcontroller: ViewController, viewModel: ViewModel? = nil) -> ViewController {

        var _viewmodel: ViewModel?
        if viewModel == nil {
            let model = Model()
            _viewmodel = ViewModel(model)
        } else {
            _viewmodel = viewModel
        }

        viewcontroller.viewModel = _viewmodel
        return viewcontroller
    }
}




















