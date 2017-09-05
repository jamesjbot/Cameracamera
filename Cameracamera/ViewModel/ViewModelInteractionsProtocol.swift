//
//  ViewModelProtocol.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/24/17.
//  Copyright © 2017 James Jongsurasithiwat. All rights reserved.
//

import Foundation
import Bond
import AVFoundation

/// This protocol provides access to the ViewController
protocol ViewModelInteractions: AVCapturePreviewProvider, SavedPhotoResponder {

    // The viewmodel will update this with new uiview that the ViewController needs to display.
    var lastOutlineViews: Observable<[UIView]> { get set }

    // 
    var outlineManager: OutlineManager? {get set}
}
