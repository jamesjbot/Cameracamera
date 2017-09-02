//
//  ViewModel.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/14/17.
//  Copyright © 2017 James Jongs. All rights reserved.
//


// This ViewModel manages the formating of view for the viewcontroller to show.
// This model manages showing views
// It managed the state of the outlines so they can stay on screen longer and not flicker.
// The views will automatically remove themselves

import Foundation
import UIKit
import AVFoundation
import Bond
import ReactiveKit
import SwiftyBeaver


// MARK: -

// MARK: -
// MARK: Outline Manager Protocol

protocol OutlineManager {
    func deleteDetectedOutline(_ detectedOuline: DetectedObjectOutline) -> Bool
    func getDuplicateOutline(withCharacteristics characteristics: DetectedObjectCharacteristics) -> DetectedObjectOutline?
}


// MARK: -

class ViewModel {

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


    /**
     This function binds the ViewModel to the Model via its observable variable
     Whenever the varaible is change we receive it and process the newly recognozed objects
     */
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
}


// MARK: - ViewModelInteractions Protocol Extension

extension ViewModel: ViewModelInteractions {


    /**
     Get a preview layer for display on the viewcontroller     - Attention:

     - Returns: Returns a reference to the PreviewLayer owned by the model
     */
    internal func getCaptureVideoPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return model?.getCaptureVideoPreviewLayer()
    }
    

    /**
     Tell the model to save photo of the metadata without markup
     - Parameter completion: A Completion handler to call after we initiated the
     save.
     - Attention: **This will not save the outliens.**
     - ToDo: Implement a version of this to save outlines too.
     */
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
    }
}


// MARK: -
// MARK: OutlineManager Protocol Extension

extension ViewModel: OutlineManager {

    /**
     This method deletes an outline from the collection

     - Parameters: The Outline you would like to delete
     - Returns: A boolean indication success 'true' or failure 'false'
     - Note: Currently any qrcode with the exact same payload will be save in the exact same sub-collection
     */
    internal func deleteDetectedOutline(_ detectedOuline: DetectedObjectOutline) -> Bool {

        // Make sure the array containing the duplicate string payloads exists
        guard let array = dictionaryOfDistinctStringPayload[detectedOuline.decodedPayload] else {
            return false
        }

        // Remove the whole array from the dictionary if there is only 1 outline in it
        if (array.count) == 1 {
            dictionaryOfDistinctStringPayload.removeValue(forKey: detectedOuline.decodedPayload)
            return true
        }

        // Remove the exact outline from the multiple same payloads in the dictionary
        let closure: (DetectedObjectOutline) -> (Bool) = {($0.similar(toCharacteristics: detectedOuline.characteristics!))}

        // Remove the outline at the desired position
        if let index = dictionaryOfDistinctStringPayload[detectedOuline.decodedPayload]?
            .index(where: closure) {
            dictionaryOfDistinctStringPayload[detectedOuline.decodedPayload]?.remove(at: index)
            return true
        }
        return false
    }


    /**
     This function searches thru the dictionary to return an outline matching
     the position and payload provided by the parameters.

     - Parameters:
        - withCharacteristics: The detected object characteristics you are looking for
        - juice: The type of juice you like to drink
     - Returns: The DetectedObjectOutline or nil
     */
    internal func getDuplicateOutline(withCharacteristics characteristics: DetectedObjectCharacteristics) -> DetectedObjectOutline? {

        let payload = characteristics.payload

        // We must have a array representing the loctions of the payload (QRCode)
        // This array contains the exact same qr codes at different locations
        guard let arrayOfSamePayloadOutlines = dictionaryOfDistinctStringPayload[payload] else {
            return nil
        }

        // Match the first outline with the same outline characteristics
        for outline in arrayOfSamePayloadOutlines {
            if outline.characteristics == characteristics {
                return outline
            }
        }
        SwiftyBeaver.verbose("Failed to find a duplicate Outline")
        return nil
    }
}























