//
//  Mocks.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 9/3/17.
//  Copyright © 2017 James Jongs. All rights reserved.
//

import UIKit
import Foundation
import XCTest
import Bond
import AVFoundation

@testable import Cameracamera

class MockModel: ModelInteractions, AVCapturePreviewProvider {

    var receivedViewControlleAndSetAVCaptureVideoPreviewLayer: Bool = false

    var metadataCodeObjects: MutableObservableArray<MetaDataObjectAndPayload> = MutableObservableArray<MetaDataObjectAndPayload>([])

    func attachAVCapturePreview(toReceiver: AVCapturePreviewReceiver) -> AVCapturePreviewReceiver? {
        let receiver = toReceiver.attachToSelf(preview: AVCaptureVideoPreviewLayer())
        receivedViewControlleAndSetAVCaptureVideoPreviewLayer = true
        return receiver
    }
    
    func savePhoto(_ completion: ((Bool)->())? = nil ) {
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) {
            timer in
            completion?(true)
        }
    }


    func generateFakeMetadataCodeObject(numberOfFakes: Int, testExpectation: XCTestExpectation,allOverlapping: Bool = false) {
        let position = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        var localArray: [MetaDataObjectAndPayload] = []
        if allOverlapping {
            for _ in 0..<numberOfFakes {
                localArray.append(MetaDataObjectAndPayload(bounds: position, payload: "test", type: "QRCode"))
            }
        } else {
            for i in 0..<numberOfFakes {
                let position = CGRect(x: CGFloat(i*2), y: 0.0, width: 1.0, height: 1.0)
                localArray.append(MetaDataObjectAndPayload(bounds: position, payload: "testNonoverlapping", type: "QRcode"))
            }
        }

        metadataCodeObjects.replace(with: localArray)
        testExpectation.fulfill()
    }
}

class MockViewModel: ViewModelInteractions, AVCapturePreviewProvider {
    var model = MockModel()
    var lastOutlineViews = Observable<[UIView]>([])
    var outlineManager: OutlineManager?
    func savePhoto(_ completion: ((Bool)->())?) {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) {
            _ in
            completion?(true)
        }
    }
    func attachAVCapturePreview(toReceiver: AVCapturePreviewReceiver) -> AVCapturePreviewReceiver? {
        return model.attachAVCapturePreview(toReceiver: toReceiver)
    }

}

