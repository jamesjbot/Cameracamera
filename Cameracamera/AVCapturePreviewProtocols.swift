//
//  AVCapturePreviewProtocols.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 9/2/17.
//  Copyright © 2017 James Jongs. All rights reserved.
//

import AVFoundation

protocol AVCapturePreviewProvider {

    func attachAVCapturePreview(toReceiver: AVCapturePreviewReceiver) -> AVCapturePreviewReceiver?
}

protocol AVCapturePreviewReceiver {

    func attach(preview videoPreview: AVCaptureVideoPreviewLayer) -> AVCapturePreviewReceiver?
}
