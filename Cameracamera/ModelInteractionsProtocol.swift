//
//  ModelProtocol.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/24/17.
//  Copyright © 2017 James Jongsurasithiwat. All rights reserved.
//

import Foundation
import AVFoundation
import Bond

protocol ModelInteractions: AVCapturePreviewProvider {

    var metadataCodeObjects: MutableObservableArray<MetaDataObjectAndPayload> { get }

    func savePhoto(_ completion: ((Bool)->())?)
}
