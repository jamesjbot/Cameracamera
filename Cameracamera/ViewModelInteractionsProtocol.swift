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

protocol ViewModelInteractions: AVCapturePreviewProvider {

    var lastOutlineViews: Observable<[UIView]> { get set }

    func savePhoto(_ completion: ((Bool)->())?)
}
