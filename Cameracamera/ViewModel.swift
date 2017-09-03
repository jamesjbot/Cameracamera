//
//  ViewModel.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/14/17.
//  Copyright © 2017 James Jongsurasithiwat. All rights reserved.
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
// MARK: Outline Manager Protocol

protocol OutlineManager {
    func deleteDetectedOutline(_ detectedOuline: DetectedObjectOutline) -> Bool
    func getDuplicateOutline(withCharacteristics characteristics: DetectedObjectCharacteristics) -> DetectedObjectOutline?
}


// MARK: -

class ViewModel {

    // MARK: Variables

    private var backingInt = Int.min
    private var outlineProcessingCycleID: Int {
        get {
            if backingInt >= Int.max-1 {
                backingInt = Int.min
            }
            backingInt += 1
            return backingInt
        }
    }

    // Holds all the outlines that are being displayed
    fileprivate var dictionaryOfDistinctStringPayload: [String:[DetectedObjectOutline]] = [:]

    // Holds all the new outlines that need to be displayed
    internal var lastOutlineViews:Observable<[UIView]> = Observable([])

    fileprivate var model: ModelInteractions?


// MARK: Functions

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

            let objects: [MetaDataObjectAndPayload] = event.source.array

            let processingID = self.outlineProcessingCycleID
            SwiftyBeaver.verbose("\n_________________\nViewModel \(#function) observer iteration: \(processingID) with \(objects.count) objects")

            // Clean out all previous views so we don't resend them to the ViewController
            //: - Note: This will instantly call the viewcontroller's bindViewModel
            self.lastOutlineViews.value.removeAll(keepingCapacity: true)

            self.processEveryMetadataObject(objects: objects)

            // By replacing this value the signal will fire and the observer can see the changes
            //self.lastOutlineViews.value = views
            SwiftyBeaver.verbose("\nViewModel \(#function) observer iteration:\(processingID) complete!\n^^^^^^^^^^^^^^^^^^^\n")
        }
    }


    /**
     This will process every metadata objects

     - Note: This is where you will want to add future code types or feature processing
     - Parameter objects: And array of [MetaDataObjectAndPayload]

     */
    internal func processEveryMetadataObject(objects :[MetaDataObjectAndPayload]) {

        for object in objects {
            let outlineCharacteristics =
                DetectedObjectCharacteristics(payload: object.payload,
                                              origin: object.metaDataObject.bounds,
                                              codeType: object.metaDataObject.type)

            let duplicateOutline = self.getDuplicateOutline(withCharacteristics: outlineCharacteristics)

            if duplicateOutline == nil {

                let _ = self.createNewOutlineInCollection(withCharacteristics: outlineCharacteristics)
            }
            else // We have a this outline already present and accounted for.
            {
                // Rest the items death timer
                duplicateOutline?.keepAlive = true
            }
        }
    }


    /**
     This function will create the outline and place it in the dictionary for tracking.

     - Parameters:
        - withCharacteristics: Is the characteristics you want for the outline.
     - Returns: Returns the newly created outline
     */
    internal func createNewOutlineInCollection(withCharacteristics characteristics: DetectedObjectCharacteristics) -> DetectedObjectOutline? {

        // Create an outline from the characteristics
        let targetOutline = DetectedObjectOutline(characteristics: characteristics, viewModel: self)

        // Save the outline in our system.
        self.put(thisNew: targetOutline,
                 into: self.dictionaryOfDistinctStringPayload)

        // Add the view to the queue for display in the viewcontroller
        self.lastOutlineViews.value.append(targetOutline.uiViewRepresentation!)

        return targetOutline
    }


    /**
     This method places the outline into the outline manager

     - Parameters:
        - thisNew: Is the Detected Outline
        - into: Is the dictionary you want to place the object into.
     */
    private func put(thisNew input: DetectedObjectOutline, into dictionaryOfOutlineArrays: [String:[DetectedObjectOutline]]) {

        let payload = input.decodedPayload

        // We must have a array representing the loctions of the payload (QRCode)
        guard dictionaryOfOutlineArrays[payload] != nil else {
            // Create a new array of qrcode locations for a particular payload (QRCode)
            // And add the DetectedOutline to nit to the dictionary
            dictionaryOfDistinctStringPayload[payload] = [input]
            return
        }

        // Array for a particular payload already exists, just append the new outline to the array
        dictionaryOfDistinctStringPayload[payload]?.append(input)
    }
}


// MARK: -
// MARK: AVCapturePreviewProvider Extension

extension ViewModel: AVCapturePreviewProvider {

    /**
     Attaches an AVCapture preview layer to whatever would like it

     - Returns: Returns a reference to the PreviewLayer owned by the model
     */
    func attachAVCapturePreview(toReceiver: AVCapturePreviewReceiver) -> AVCapturePreviewReceiver? {

        return model?.attachAVCapturePreview(toReceiver: toReceiver)
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
        if let completion = completion {
            completion(true)
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























