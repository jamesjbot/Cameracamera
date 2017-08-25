//
//  ModelProtocol.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/24/17.
//  Copyright © 2017 James Jongs. All rights reserved.
//

import Foundation
import AVFoundation
import Bond

protocol ModelInteractions {

    var metadataCodeObjects: MutableObservableArray<AVMetadataMachineReadableCodeObject> { get }
    func getCaptureVideoPreviewLayer() -> AVCaptureVideoPreviewLayer?
    func savePhoto()
}
