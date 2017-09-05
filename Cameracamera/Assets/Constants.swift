//
//  Constants.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/25/17.
//  Copyright © 2017 James Jongsurasithiwat. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

enum Constants {
    static let offset = CGFloat(20)
    static let scaling = CGFloat(1.15)
    static let ourBorderColor = UIColor.red.cgColor
    static let ourBorderWidth = CGFloat(3.0)
    static let avCaptureScale = CGFloat(1.0)
    static let fullPixelSize = CGFloat(0.0)
}

enum SwiftyBeaverConstants {
    static let PathComponent = "swiftybeaver"
    static let PathExtension = "log"
}

enum DetectedObjectOutlineConstants {
    static let margin = CGFloat(10.0)
    static let originMeasurementErrorRange = CGFloat(0.001) // This should be a % of the view window pixels.
    static let screenWidth = UIScreen.main.bounds.width
    static let timeToKeepAlive = 0.2
}

enum ModelError: Error {
    case CaptureOutputNotOpen
    case PhotoSampleBufferNil
    case InitializeCaptureInputError
    case JPEGPhotoRepresentationError
}

// Specify the types of metadata you want to identify
struct AcceptableMetadataTypes {
    static let desiredTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode]
}








