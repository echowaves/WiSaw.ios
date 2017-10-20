//
//  Photo.swift
//  Echowaves
//
//  Created by D on 10/19/17.
//  Copyright © 2017 EchoWaves. All rights reserved.
//

import Foundation
import UIKit

class Photo {
    // all of the fields mandatory
    var id: Int
    var timeStamp: Date
    var photo: UIImage
    var thumbNail: UIImage
    var owner: String //UUID of the originating device
    var distance: Int
    
    
    init(id: Int, timeStamp: Date, photo: UIImage, thumbNail: UIImage, owner: String, distance: Int) {
        self.id = id
        self.timeStamp = timeStamp
        self.photo = photo
        self.thumbNail = thumbNail
        self.owner = owner
        self.distance = distance
    }
}
