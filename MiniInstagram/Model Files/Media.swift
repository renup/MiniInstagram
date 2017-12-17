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
    var carouselMedia: [JSON]?
    
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
        carouselMedia = json["carousel_media"].arrayValue
        print("carousal = \(String(describing: carouselMedia))")
    }
}

struct AlbumContent {
    var imageURLStr: String?
    
    init(urlString: String) {
        imageURLStr = urlString
    }
    
//    init(album: Media) {
//        if let imagesArray = album.carouselMedia as? Array<JSON> {
//            for subJson in imagesArray {
//                let imgString = subJson["images"]["low_resolution"].stringValue
//                albumMedia?.append(imgString)
//            }
//        }
//    }
}
