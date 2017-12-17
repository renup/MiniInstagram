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
    var carouselMedia: Any?
    
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
       
        //// If json is .Array
        // The `index` is 0..<json.count's string value
//        for (index,subJson):(String, JSON) in json {
//            // Do something you want
//        }
        carouselMedia = json["carousel_media"]
        print("carousal = \(String(describing: carouselMedia))")
    }
}
