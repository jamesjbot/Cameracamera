//
//  ViewModelProtocol.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/24/17.
//  Copyright © 2017 James Jongs. All rights reserved.
//

import Foundation
import Bond
import AVFoundation

protocol ViewModelInteractions {
    var lastOutlineViews: Observable<[UIView]> { get set }

    func getCaptureVideoPreviewLayer() -> AVCaptureVideoPreviewLayer?
    func savePhoto(_ completion: ((Bool)->())?)
    //var metadataCodeObjects: ObservableArray<AVMetadataMachineReadableCodeObject> { get }
}
