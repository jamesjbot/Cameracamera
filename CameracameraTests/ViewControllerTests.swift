//
//  ViewControllerTests.swift
//  ViewControllerTests
//
//  Created by James Jongsurasithiwat on 8/8/17.
//  Copyright © 2017 James Jongsurasithihiwat. All rights reserved.
//

import XCTest
import AVFoundation
import Bond

@testable import Cameracamera

class ViewControllerToViewModelTests: XCTestCase {

    var viewController: ViewController?
    var viewModel: ViewModelInteractions?

    override func setUp() {

        super.setUp()

        viewModel = MockViewModel()
        
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController

        let _ = DependencyInjector.attachViewModelInteractions(to: viewController!, viewModel: viewModel)
        guard viewController != nil else {
            fatalError("Viewcontroller is nil")
        }
    }


    override func tearDown() {
        viewModel = MockViewModel()
        super.tearDown()
    }
//
//    func testObservingLastOutlineViews() {
//        // Given:
//        let arrayOfViews = viewController?.previewView?.subviews
//        var priorcount: Int? = arrayOfViews == nil ? 0 : arrayOfViews?.count
//        let returnViewController = model?.attachAVCapturePreview(toReceiver: viewController!)
//        if let postViews = viewController?.previewView?.subviews {
//        }
////        var postcount: Int? = postView == nil ? 0 : postViews?.count
//
//        // When:
//        viewModel?.lastOutlineViews.value.append(UIView())
//
//        // Then:
//        XCTAssert((count + 1) == (viewController?.previewView.subviews.count)!)
//    }

    func testsavePhotoWithNoQRCodes() {
        //_ completion: ((Bool)->())?
        // Given:
        let promise = XCTestExpectation(description: "Return with true")
        var shouldBeTree = false
        let handler: ((Bool,Error?) -> ())? = {
            result, error in
            shouldBeTree = result
            promise.fulfill()
        }
        // When:
        viewModel?.savePhoto(delegate: nil, completion: handler)
        // Then:

        wait(for: [promise], timeout: 10.0)
        XCTAssert(shouldBeTree)
    }



//    func testcreateOutlineUIViews() {
//        // Given: We have a MetaDataObjectAndPayload
//        //let metadataObject: AVMetadataObject = MyMetaDataObject()
//        let text = "www.google.com"
//        let sometype = AVMetadataMachineReadableCodeObject.
//        _ = MetaDataObjectAndPayload(bounds: <#T##CGRect#>, payload: <#T##String#>, type: <#T##String#>)
//    }


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











