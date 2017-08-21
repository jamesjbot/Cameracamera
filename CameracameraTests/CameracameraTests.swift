//
//  CameracameraTests.swift
//  CameracameraTests
//
//  Created by James Jongsurasithiwat on 8/8/17.
//  Copyright © 2017 James Jongs. All rights reserved.
//

import XCTest
import AVFoundation

@testable import Cameracamera

class CameracameraTests: XCTestCase {

    var testModel: Model?
    var mockPreview: MockPreview?
    var mockWindow: MockWindow?

    override func setUp() {
        super.setUp()
        mockPreview = MockPreview()
        //testModel = Model(preview: mockPreview!)
        mockWindow = MockWindow()
    }


    override func tearDown() {
        mockPreview = nil
        testModel = nil
        super.tearDown()
    }


    func testcreateOutlineUIViews() {
        // Given: We have a MetaDataObjectAndPayload
        let metadataObject: AVMetadataObject = MyMetaDataObject()
        let text = "www.google.com"
        let object = MetaDataObjectAndPayload(metaDataObject: metadataObject, payload: text)

        // When:
        let views = testModel?.createOutlineUIViews([object])

        // Then:
        print(type(of:views?.first))
        print(((views?.first?.subviews.first as! UIStackView).arrangedSubviews.first as! UILabel).text ?? "nil")

        XCTAssert(views?.first?.bounds == CGRect(x: 0.0, y: 0.0, width: 20*Constants.scaling, height: 30*Constants.scaling)
            &&
        ((views?.first?.subviews.first as! UIStackView).arrangedSubviews.first as! UILabel).text == AVMetadataObjectTypeQRCode
            &&
       ((views?.first?.subviews.first as! UIStackView).arrangedSubviews.last as! UILabel).text == "www.google.com"
        )
    }


//    func testAttachOutlinesToWindow() {
//        // Given: We have a MetaDataObjectAndPayload
//        let metadataObject: AVMetadataObject = MyMetaDataObject()
//        let text = "www.google.com"
//        let object = MetaDataObjectAndPayload(metaDataObject: metadataObject, payload: text)
//        let views = testModel?.createOutlineUIViews([object])
//
//        // When:
//        testModel?.attach(outlines: views!, to: mockWindow!)
//
//        // Then:
//        XCTAssertTrue((mockWindow?.subviewsAdded)!)
//    }


}

protocol MockPreviewIntrospection {

    var isAVCaptureVideoPreviewLayerAttachedToMockPreview: Bool? { get set }
    var didMockPreviewAcceptError: Bool? { get set }
}

class MockPreview: MockPreviewIntrospection {

    var previewView: UIView!
    var fullview: UIView!

    var isAVCaptureVideoPreviewLayerAttachedToMockPreview: Bool?
    var didMockPreviewAcceptError: Bool?

    init() {

        previewView = UIView()
        fullview = UIView()
        isAVCaptureVideoPreviewLayerAttachedToMockPreview = false
    }


    func attachPreview(preview: AVCaptureVideoPreviewLayer) {

        isAVCaptureVideoPreviewLayerAttachedToMockPreview = true
    }


    func acceptError(error: String) {

        didMockPreviewAcceptError = true
    }
}


class MyMetaDataObject: AVMetadataObject {

    var mybounds: CGRect = CGRect(x: 0, y: 0, width: 20, height: 30)

    override var bounds: CGRect {
        get {
            return mybounds
        }

        set {
            mybounds = newValue
        }
    }


    var myTypeCode = AVMetadataObjectTypeQRCode

    override var type: String {

        get {
            return myTypeCode
        }

        set {
            myTypeCode = newValue
        }
        
    }
    
    override init() {
        super.init()
    }
}


class MockWindow: UIWindow {

    var subviewsAdded: Bool = false

    override func addSubview(_ view: UIView) {

        subviewsAdded = true
    }
}










