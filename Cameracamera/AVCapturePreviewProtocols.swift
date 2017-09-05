//
//  AVCapturePreviewProtocols.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 9/2/17.
//  Copyright © 2017 James Jongs. All rights reserved.
//

import AVFoundation
import UIKit

protocol AVCapturePreviewProvider {

    func attachAVCapturePreview(toReceiver: AVCapturePreviewReceiver) -> AVCapturePreviewReceiver?
}

protocol AVCapturePreviewReceiver {

    func attachToSelf(preview videoPreview: AVCaptureVideoPreviewLayer) -> AVCapturePreviewReceiver?
}

protocol SavedPhotoResponder {
    func savePhoto(delegate: AVCapturePhotoCaptureDelegate?,
                   completion: ( (Bool,Error?)->() )?)
}
