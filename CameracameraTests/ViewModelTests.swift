//
//  ViewModelTests.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/24/17.
//  Copyright © 2017 James Jongs. All rights reserved.
//

import XCTest
import Bond
import AVFoundation

@testable import Cameracamera

class ViewModelTests: XCTestCase {

    var viewController: ViewController?
    var viewModel: ViewModel?
    var model: MockModel?

    override func setUp() {
        super.setUp()

        model = MockModel()
        viewModel = ViewModel(model!)

        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController

        let _ = DependencyInjector.attachViewModel(to: viewController!, viewModel: viewModel)

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
        model = nil
        super.tearDown()
    }

    func testViewModelReceivesAViewFromPropertyMetadataCodeObjects() {
        // given:
        // viewModel receives a new outline.
        model?.generateFakeMetadataCodeObject()

        // viewModel waits for short duration
        // when: we Delay
        for _ in 1...1000 {
        }

        // then:
        XCTAssert(viewModel?.lastOutlineViews.value.count == 1, "viewModel did not receive a view \(String(describing: viewModel?.lastOutlineViews.value.count))")
    }

    func testViewModelReceivesMultipleViewsMetadataCodeObjects() {
        // given:
        // viewModel receives 3 new outlines.
        model?.generateFakeMetadataCodeObject()
        model?.generateFakeMetadataCodeObject()
        model?.generateFakeMetadataCodeObject()

        // viewModel waits for short duration
        // when: we delay
        for _ in 1...1000 {
        }

        // then:
        XCTAssert(viewModel?.lastOutlineViews.value.count == 3, "viewModel did not receive 3 view \(String(describing: viewModel?.lastOutlineViews.value.count))")
    }

    func testViewModelGettingVideoPreviewLayer() {
        // given:

        // when:
        let previewLayer = model?.getCaptureVideoPreviewLayer()

        // then:
        XCTAssertNotNil(previewLayer)
    }


    func testViewModelSavingPhoto() {
        // given:
        let expectation = self.expectation(description: "Wait for results")
        expectation.expectedFulfillmentCount = 1

        // when:
        var result: Bool?
        model?.savePhoto {
            success -> () in
            result = success
            expectation.fulfill()
        }

        // then:
        waitForExpectations(timeout: 30.0) {
            error in
            XCTAssertTrue(result!)
        }
    }



}

class MockModel: ModelInteractions {

    var metadataCodeObjects: MutableObservableArray<MetaDataObjectAndPayload> = MutableObservableArray<MetaDataObjectAndPayload>([])


    func getCaptureVideoPreviewLayer() -> AVCaptureVideoPreviewLayer? {

        return AVCaptureVideoPreviewLayer()
    }


    func savePhoto(_ completion: ((Bool)->())? = nil ) {
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) {
            timer in
            completion?(true)
        }
    }


    func generateFakeMetadataCodeObject() {
        metadataCodeObjects.append(MetaDataObjectAndPayload(metaDataObject: AVMetadataMachineReadableCodeObject(), payload: "Test"))
    }
}




















