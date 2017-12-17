//
//  Media.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/14/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Media {
    var userName: String?
    var imageURLString: String?
    
    init(mediaAlbum: (String, JSON)) {
        print("mediaAlbum = \(mediaAlbum)")
        let json = mediaAlbum.1
        let albumImage = json["images"]["low_resolution"]["url"].stringValue
        #if debug
            print("albumImag = \(albumImage)")
        #endif
        imageURLString = albumImage
        let name = json["user"]["full_name"].stringValue
        userName = name
    }
}
