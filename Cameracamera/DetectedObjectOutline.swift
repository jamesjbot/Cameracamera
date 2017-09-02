//
//  DetectedObjectOutline.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/31/17.
//  Copyright © 2017 James Jongsurasithiwat. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import SwiftyBeaver

// MARK: -
// Helper Struct

struct DetectedObjectCharacteristics: Equatable {

    let codeType: String
    let payload: String
    let origin: CGRect

    init(payload: String, origin: CGRect, codeType: String) {

        self.codeType = codeType
        self.payload = payload
        self.origin = origin
    }


    static func ==(lhs: DetectedObjectCharacteristics, rhs: DetectedObjectCharacteristics) -> Bool {

        if lhs.payload == rhs.payload && lhs.origin.intersects(rhs.origin) {
            return true
        }
        return false
    }


    func isSimilar(to rhs: DetectedObjectCharacteristics) -> Bool {

        return self == rhs
    }
}

// MARK: -


protocol SelfTerminatingDrawableOutline {

    var characteristics: DetectedObjectCharacteristics? {get}
    var uiViewRepresentation: UIView? {get}
    var decodedPayload: String {get}
    func similar(toCharacteristics: DetectedObjectCharacteristics) -> Bool
}

// MARK: - 
//
/// This object manages an outline for a QRcode
/// It has the ability to automatically remove itself from the superview and container.
/// It's eventual demise can be delayed by setting the keepAlive variable to true
///
///

class DetectedObjectOutline: Hashable, CustomStringConvertible {

    // MARK: Constants

    private let ORIGIN_MEASUREMENT_ERROR_RANGE = CGFloat(0.001) // This should be a % of the view window pixels.
    private let SCREENWIDTH = UIScreen.main.bounds.width
    fileprivate let TIME_TO_KEEP_ALIVE = 0.2

    fileprivate let viewModelContainingThis: OutlineManager?

    // MARK: Variables
    internal var characteristics: DetectedObjectCharacteristics?
    fileprivate var creationTime = Date()
    internal var decodedPayload: String = ""

    internal var description: String {
        let description = "<\(Unmanaged.passUnretained(self as AnyObject).toOpaque())> \(String(describing: characteristics?.payload))"
        return description
    }

    internal var hashValue: Int {
        return creationTime.hashValue
    }

    internal var keepAlive: Bool = false

    fileprivate var timer: Timer?

    internal var uiViewRepresentation: UIView? = nil

    // MARK: Methods

    deinit {
        SwiftyBeaver.info("Deinitialize called on DetectedObjectOutline \(description)")
    }

    init(characteristics: DetectedObjectCharacteristics, viewModel: ViewModel) {

        self.characteristics = characteristics

        viewModelContainingThis = viewModel

        decodedPayload = characteristics.payload

        setupUIViewRepresentation(with: characteristics)

        // Start a new timer to delete the outline after a certain amount of time
        setNewTimer()
    }
    

    static func ==(lhs: DetectedObjectOutline, rhs: DetectedObjectOutline) -> Bool {
        return lhs.characteristics == rhs.characteristics
    }
}

extension DetectedObjectOutline: SelfTerminatingDrawableOutline {

    func similar(toCharacteristics: DetectedObjectCharacteristics) -> Bool {
        return characteristics == toCharacteristics
    }
}

extension DetectedObjectOutline {

    fileprivate func setupUIViewRepresentation(with characteristics: DetectedObjectCharacteristics) {

        let bounds = characteristics.origin
        uiViewRepresentation = UIView(frame: CGRect(x: (bounds.minX),
                                                    y: ((bounds.minY) + Constants.offset),
                                                    width: ((bounds.width) * Constants.scaling),
                                                    height: ((bounds.height) * Constants.scaling))
        )

        uiViewRepresentation?.layer.borderColor = Constants.ourBorderColor
        uiViewRepresentation?.layer.borderWidth = Constants.ourBorderWidth

        let typeLabel = createCodeTypeLabel(withCharacteristics: characteristics)

        let contentLabel = createPayloadLabel(withCharacteristics: characteristics)

        // Organize the labels presentation
        let stackView = createStackView(arrangedLabels: [typeLabel,contentLabel])

        // Attach the labels to the view
        uiViewRepresentation?.addSubview(stackView)
    }


    fileprivate func createCodeTypeLabel(withCharacteristics characteristics:

        DetectedObjectCharacteristics) -> UILabel {
        // Displays the type of code
        let typeLabel = UILabel()
        typeLabel.attributedText = NSAttributedString(string: characteristics.codeType)
        typeLabel.textColor = UIColor.green
        typeLabel.backgroundColor = UIColor.gray
        typeLabel.adjustsFontSizeToFitWidth = true
        return typeLabel
    }


    fileprivate func createPayloadLabel(withCharacteristics characteristics: DetectedObjectCharacteristics) -> UILabel {

        // Displays the encoded information
        let contentLabel = UILabel()
        contentLabel.attributedText = (NSAttributedString(string: characteristics.payload))
        contentLabel.textColor = UIColor.cyan
        contentLabel.backgroundColor = UIColor.gray
        contentLabel.adjustsFontSizeToFitWidth = true
        decodedPayload = characteristics.payload
        return contentLabel
    }


    fileprivate func createStackView(arrangedLabels: [UILabel]) -> UIStackView {

        let stackView = UIStackView(arrangedSubviews: arrangedLabels)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.layoutMargins = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        stackView.isLayoutMarginsRelativeArrangement = true
        if let bounds = self.uiViewRepresentation?.bounds {
            stackView.frame = bounds
        }
        return stackView
    }


    fileprivate func removeOutlineFromSuperviewAndRemoveFromViewModel() {

        DispatchQueue.main.async {
            let _ = self.viewModelContainingThis?.deleteDetectedOutline(self)
            
            assert(self.viewModelContainingThis?.getDuplicateOutline(withCharacteristics: self.characteristics!) == nil)

            self.uiViewRepresentation?.removeFromSuperview()

            assert(self.uiViewRepresentation?.superview == nil)
        }
    }


    /// Creates
    fileprivate func setNewTimer() {

        let timerCompletionBlock: (Timer) -> () = {
            [weak self] timer in
            if self?.keepAlive == false {
                self?.removeOutlineFromSuperviewAndRemoveFromViewModel()
                timer.invalidate()
                return
            }
            self?.keepAlive = false
        }

        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: self.TIME_TO_KEEP_ALIVE, repeats: true, block: timerCompletionBlock)
        }
    }
}
















