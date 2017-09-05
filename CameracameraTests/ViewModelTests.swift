////
////  ViewModelTests.swift
////  Cameracamera
////
////  Created by James Jongsurasithiwat on 8/24/17.
////  Copyright © 2017 James Jongsurasithiwat. All rights reserved.
////
import UIKit
import Foundation
import XCTest
import Bond
import AVFoundation

@testable import Cameracamera

class ViewModelToModelTests: XCTestCase {

    var viewController: ViewController?
    var viewModel: ViewModel?
    var mockModel: MockModel?
    var window: UIWindow?

    override func setUp() {
        super.setUp()

        mockModel = MockModel()
        viewModel = ViewModel(mockModel!)

        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = viewController
        
        let _ = DependencyInjector.attachViewModelInteractions(to: viewController!, viewModel: viewModel)
        // Put setup code here. This method is called before the invocation of each test method in the class.
        assert(viewController?.mainView.layer.bounds != nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
        mockModel = nil
        super.tearDown()
    }

    
    func testViewModelReceivesAViewFromPropertyMetadataCodeObjects() {
        // given:
        // viewModel receives a new outline.
        let expectation = XCTestExpectation(description: "Finished creating fake metadata")

        // when: we Delay
        mockModel?.generateFakeMetadataCodeObject(numberOfFakes: 1,
                                                  testExpectation: expectation,
                                                  allOverlapping: false)


        // then:
        wait(for: [expectation], timeout: 5.0)
        XCTAssert(viewModel?.lastOutlineViews.value.count == 1, "viewModel did not receive a view \(String(describing: viewModel?.lastOutlineViews.value.count))")
    }


    func testViewModelReceivesMultipleViewsMetadataCodeObjectsNonOverlapping() {
        // given:
        // viewModel receives 3 new outlines.
        let expectation1 = XCTestExpectation(description: "Finished creating fake metadata 1")
        //let expectation2 = XCTestExpectation(description: "Finished creating fake metadata 2")
        //let expectation3 = XCTestExpectation(description: "Finished creating fake metadata 3")

        // when: we create 3 new test data objects
        mockModel?.generateFakeMetadataCodeObject(numberOfFakes: 3,
                                                  testExpectation: expectation1,
                                                  allOverlapping: false)
        //mockModel?.generateFakeMetadataCodeObject(testExpectation: expectation2)
        //mockModel?.generateFakeMetadataCodeObject(testExpectation: expectation3)

        // then:
        wait(for: [expectation1], timeout: 5)
        XCTAssert(viewModel?.lastOutlineViews.value.count == 3, "viewModel did not receive 3 view \(String(describing: viewModel?.lastOutlineViews.value.count))")
    }

    func testViewModelReceivesMultipleViewsMetadataCodeObjectsOverlapping() {
        // given:
        // viewModel receives 3 new outlines.
        let expectation1 = XCTestExpectation(description: "Finished creating fake metadata 1")
        //let expectation2 = XCTestExpectation(description: "Finished creating fake metadata 2")
        //let expectation3 = XCTestExpectation(description: "Finished creating fake metadata 3")

        // when: we create 3 new test data objects
        mockModel?.generateFakeMetadataCodeObject(numberOfFakes: 3,
                                                  testExpectation: expectation1,
                                                  allOverlapping: true)
        //mockModel?.generateFakeMetadataCodeObject(testExpectation: expectation2)
        //mockModel?.generateFakeMetadataCodeObject(testExpectation: expectation3)

        // then:
        wait(for: [expectation1], timeout: 5)
        XCTAssert(viewModel?.lastOutlineViews.value.count == 1, "viewModel did not receive 3 view \(String(describing: viewModel?.lastOutlineViews.value.count))")
    }

    func testViewModelSavingPhoto() {
        // given:
        let expectation = self.expectation(description: "Wait for results")
        expectation.expectedFulfillmentCount = 1

        // when:
        var result: Bool?
        mockModel?.savePhoto(delegate: nil) {
            success,error -> () in
            result = success
            expectation.fulfill()
        }

        // then:
        waitForExpectations(timeout: 30.0) {
            error in
            XCTAssertTrue(result!)
        }
    }


    func testViewModelAttachingPreviewToAnInputViewController() {
        // given:

        // when:
        let returnViewController = mockModel?.attachAVCapturePreview(toReceiver: viewController!)

        // then:
        XCTAssertNotNil(returnViewController)
        guard let mM = mockModel else {
            fatalError()
        }
        XCTAssert(mM.receivedViewControlleAndSetAVCaptureVideoPreviewLayer)
    }

}




















