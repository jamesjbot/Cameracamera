//
//  ViewModel.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/14/17.
//  Copyright © 2017 James Jongs. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Bond


protocol CapturePhoto {
    var metadataCodeObjects: ObservableArray<AVMetadataMachineReadableCodeObject> { get }
    func savePhoto()
}


protocol ViewModelInteractions {
    var lastOutlineViews: ObservableArray<UIView> { get }
    func getCaptureVideoPreviewLayer() -> AVCaptureVideoPreviewLayer?
    //func getOutlines() -> [UIView]
    func savePhoto()
    var metadataCodeObjects: ObservableArray<AVMetadataMachineReadableCodeObject> { get }
    //func savePhoto()
}

protocol ModelInteractions {
    var metadataCodeObjects: MutableObservableArray<AVMetadataMachineReadableCodeObject> { get }
    func getCaptureVideoPreviewLayer() -> AVCaptureVideoPreviewLayer?
    func savePhoto()

}


class ViewModel : ViewModelInteractions {

    var model: ModelInteractions?
    var lastOutlineViews = ObservableArray<UIView>([])
    internal var metadataCodeObjects = ObservableArray<AVMetadataMachineReadableCodeObject>([])

    init(_ model: ModelInteractions) {
        self.model = model
        bindModel()
    }

    private func bindModel() {

        _ = model?.metadataCodeObjects.observeNext {
            [unowned self] event in

            self.metadataCodeObjects = event.source 

            var objects: [MetaDataObjectAndPayload] = []

            for metadataObject in self.metadataCodeObjects {

                let dataAndPayload = MetaDataObjectAndPayload(metaDataObject: (self.getCaptureVideoPreviewLayer()?.transformedMetadataObject(for: metadataObject))!, payload: metadataObject.stringValue)
                objects.append(dataAndPayload)
            }

            // Convert machine code objects to UIView outlines
            guard objects.count > 0 else {
                return
            }
            self.lastOutlineViews = ObservableArray<UIView>(self.createOutlineUIViews(objects))

                //self.createOutlineUIViews(objects).array as! MutableObservableArray<UIView>
        }
    }

    private func createOutlineUIViews(_ objects: [MetaDataObjectAndPayload]) -> [UIView] {

        print(objects.count)

        var outlineViews = [UIView]()

        DispatchQueue.main.async {
            for object in objects {
                if let annotatedSquare = DetectedObjectOutline(metaDataObject: object).uiViewRepresentation {
                    outlineViews.append(annotatedSquare)
                }
            }
            //_ = objects.map { outlineViews.append( DetectedObjectOutline(metaDataObject: $0).uiViewRepresentation!) }
        }

        return outlineViews
    }

}

extension ViewModel: CapturePhoto {

    internal func savePhoto() {

        model?.savePhoto()
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





