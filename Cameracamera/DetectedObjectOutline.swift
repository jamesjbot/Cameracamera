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

// MARK: - Helper Struct
// This allows us to logically pass around qr codes and their position
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
// This protocol defines an outline object that will self terminate itself in a collection and 
// remove itself from it's presented superview.
// It's eventual demise can be delayed by setting the keepAlive variable to true

protocol SelfTerminatingDrawableOutline {

    var characteristics: DetectedObjectCharacteristics? {get}
    var decodedPayload: String {get}
    var keepAlive: Bool {get set}
    var uiViewRepresentation: UIView? {get}
    func isSimilar(toCharacteristics: DetectedObjectCharacteristics) -> Bool
}

// MARK: - 
//
/// This object manages an outline for a QRcode
/// It has the ability to automatically remove itself from the superview and container.

class DetectedObjectOutline: Hashable, CustomStringConvertible {

    // MARK: Constants
    fileprivate let MARGIN = CGFloat(10.0)
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
    

    /// This function allows us to compare DetectedObjectOutline
    /// This is so we can confrom to equatable
    static func ==(lhs: DetectedObjectOutline, rhs: DetectedObjectOutline) -> Bool {
        return lhs.characteristics == rhs.characteristics
    }
}


extension DetectedObjectOutline: SelfTerminatingDrawableOutline {

    /**
     This function allows use to check if the outline matches a specific characteristic
     - Parameter toCharacteristics: The characteristics of the outline to match to
     */
    func isSimilar(toCharacteristics: DetectedObjectCharacteristics) -> Bool {
        return characteristics == toCharacteristics
    }
}

extension DetectedObjectOutline {

    /**
     This make the UIView for onscreen presentation
     - Parameter with: This is the characteristics you want to load this outline with
     */
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


    /// This create the code type label telling the user what type of code they are looking at.
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


    /// This creates the label with the string that is encoded in the code.
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


    /// This creates the stackview we populate with labels.
    fileprivate func createStackView(arrangedLabels: [UILabel]) -> UIStackView {

        let stackView = UIStackView(arrangedSubviews: arrangedLabels)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.layoutMargins = UIEdgeInsets(top: MARGIN, left: MARGIN, bottom: MARGIN, right: MARGIN)
        stackView.isLayoutMarginsRelativeArrangement = true
        if let bounds = uiViewRepresentation?.bounds {
            stackView.frame = bounds
        }
        return stackView
    }


    /// This function is called from inside the timer block 
    /// It will remove the outline from the internal dictionary as well as the superview
    fileprivate func removeOutlineFromSuperviewAndRemoveFromViewModel() {

        DispatchQueue.main.async {
            let _ = self.viewModelContainingThis?.deleteDetectedOutline(self)
            
            assert(self.viewModelContainingThis?.getDuplicateOutline(withCharacteristics: self.characteristics!) == nil)

            self.uiViewRepresentation?.removeFromSuperview()

            assert(self.uiViewRepresentation?.superview == nil)
        }
    }


    /// Creates the new timer that will eventually remove this outline form the view.
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
















