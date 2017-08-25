//
//  ViewModel.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/14/17.
//  Copyright © 2017 James Jongs. All rights reserved.
//


// This is the ViewModel
// It manages whether the Outline of the Code should or should not be shown.


import Foundation
import UIKit
import AVFoundation
import Bond
import ReactiveKit


struct ViewModelConstants {
    static let THROTTLE_TIME = 1.0
    static let NUMBER_OF_STORED_OUTLINE_SETS = 3
}


class ViewModel : ViewModelInteractions {
    var lastOutlineViews:Observable<[UIView]> = Observable([])

    var arrayContainingLastDictionaries: [[String:DetectedObjectOutline]] = []
    var currentDictionaryOfView: [String: UIView] = [:]
    var model: ModelInteractions?
    //var lastOutlineViews = Observable<[UIView]>([])
    //internal var metadataCodeObjects = ObservableArray<AVMetadataMachineReadableCodeObject>([])

    init(_ model: ModelInteractions) {
        self.model = model
        bindModel()
    }

    private func bindModel() {

        _ = model?.metadataCodeObjects.observeNext {
            [unowned self] event in

            var objects: [MetaDataObjectAndPayload] = event.source.array

            print(objects.count)

            let views = self.createOutlineUIViews(objects)
            print("Viewmodel Replacing lastOutlineView with \(views.count)")
            let output = self.lastOutlineViews.replace(with: views)
            self.lastOutlineViews.value = views
            print("Viewmodel Before  leaving this is what lastOutlineViews has\(self.lastOutlineViews.value.count)")
            //self.lastOutlineViews.
            //let something = self.lastOutlineViews.replace(with: ObservableArray<UIView>(self.createOutlineUIViews(objects))).
            //print(type(of: something))
            //self.lastOutlineViews = ObservableArray<UIView>(self.createOutlineUIViews(objects))

                //self.createOutlineUIViews(objects).array as! MutableObservableArray<UIView>
        }
    }

    private func createOutlineUIViews(_ objects: [MetaDataObjectAndPayload]) -> [UIView] {

        print("Viewmodel createOutline received \(objects.count)")


        var dictionaryOfView = [String:DetectedObjectOutline]()
        var outlineViews = [UIView]()

            for object in objects {

                let outlineandPayload = DetectedObjectOutline(metaDataObject: object)
                    dictionaryOfView[outlineandPayload.decodedPayload!] = outlineandPayload
                    outlineViews.append(outlineandPayload.uiViewRepresentation!)
            }

        // Prune off old dictionaries
        if arrayContainingLastDictionaries.count >= ViewModelConstants.NUMBER_OF_STORED_OUTLINE_SETS {
            arrayContainingLastDictionaries.removeFirst()
        }

        // Add the new dictionary
        arrayContainingLastDictionaries.append(dictionaryOfView)

        // Rebuild a list of outlines from last groups shown
        var outputDictionary = [String:DetectedObjectOutline]()
//        for groupOfOutlines in arrayContainingLastDictionaries {
//            for outlineAndPayload in groupOfOutlines {
//                outputDictionary[outlineAndPayload.key] = outlineAndPayload.value
//            }
//        }

        print("Viewmodel Output dictionary has \(outputDictionary.count)")

            //_ = objects.map { outlineViews.append( DetectedObjectOutline(metaDataObject: $0).uiViewRepresentation!) }
        var justViews = [UIView]()
        for outlineAndPayload in outputDictionary.values {
            justViews.append(outlineAndPayload.uiViewRepresentation!)
        }
        print("Veiwmodel createoutlineView returning \(outlineViews.count)")
        return outlineViews
    }

    // Tell the model to save photo of the metadata
    internal func savePhoto(_ completion: ((Bool)->())? = nil ) {

        model?.savePhoto(nil)
    }

}


extension ViewModel {

    internal func getCaptureVideoPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return model?.getCaptureVideoPreviewLayer()
    }

    internal func getOutlines() -> [UIView] {
        return [UIView()]
    }
}


// MARK: - Helper Struct

struct DetectedObjectOutline {

    var uiViewRepresentation: UIView? = nil
    var decodedPayload: String? = nil

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
        decodedPayload = metaDataObject.payload

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


// MARK: -
class Outline {


    // MARK: Constants

    let MAXIMUM_ONSCREEN_DURATION = 0.5
    let ORIGIN_MEASUREMENT_ERROR_RANGE = 0.01

    // MARK: Variables

    var startTime = ProcessInfo.processInfo.systemUptime
    var outline: UIView?
    var decodedStringPaylod: String?

    // MARK: Methods

    init(_ outline: UIView, payload: String) {
        self.outline = outline
        decodedStringPaylod = payload
    }


    func hasExceededOnScreenDuration() -> Bool {
        let currentTime = ProcessInfo.processInfo.systemUptime
        if startTime + MAXIMUM_ONSCREEN_DURATION >= currentTime {
            return true
        }
        return false
    }


    func isEqual(_ input: Outline) -> Bool {

        // Check payload is the same
        guard decodedStringPaylod == input.decodedStringPaylod else {
            return false
        }

        // Check origin position is close
        guard let x = outline?.frame.origin.x else {
            return false
        }
        var low = x * CGFloat( 1 - ORIGIN_MEASUREMENT_ERROR_RANGE )
        var high = x * CGFloat( 1 + ORIGIN_MEASUREMENT_ERROR_RANGE )
        guard low...high ~= (input.outline?.frame.origin.x)! else {
            return false
        }

        guard let y = outline?.frame.origin.y else {
            return false
        }
        low = y * CGFloat( 1 - ORIGIN_MEASUREMENT_ERROR_RANGE )
        high = y * CGFloat( 1 + ORIGIN_MEASUREMENT_ERROR_RANGE )
        guard low...high ~= (input.outline?.frame.origin.y)! else {
            return false
        }

        return true
    }


}

















