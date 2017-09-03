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

/// This protocol provides the ViewModel with access into the Model.
protocol ModelInteractions: AVCapturePreviewProvider {

    // This is update with metadata object detected in the last cycle
    var metadataCodeObjects: MutableObservableArray<MetaDataObjectAndPayload> { get }

    // This function allows us to call down to the model to take a picture.
    func savePhoto(_ completion: ((Bool)->())?)
}
