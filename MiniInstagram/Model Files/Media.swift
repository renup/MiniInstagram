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
    var mediaId: String?
    var userLiked: Bool?
    
    init(mediaAlbum: (String, JSON)) {
        let json = mediaAlbum.1
        mediaId = json["id"].stringValue
        userLiked = json["user_has_liked"].boolValue
        imageURLString = json["images"]["low_resolution"]["url"].stringValue
        userName = json["user"]["full_name"].stringValue
        carouselMedia = json["carousel_media"].arrayValue
        #if DEBUG
            print("mediaAlbum = \(mediaAlbum)")
        #endif
    }
}

struct AlbumContent {
    var imageURLStr: String?
    
    init(urlString: String) {
        imageURLStr = urlString
    }
}
