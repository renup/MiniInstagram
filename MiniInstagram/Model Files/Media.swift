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
        print("mediaAlbum = \(mediaAlbum)")
        let json = mediaAlbum.1
        mediaId = json["id"].stringValue
        userLiked = json["user_has_liked"].boolValue
        let albumImage = json["images"]["low_resolution"]["url"].stringValue
        #if debug
            print("albumImag = \(albumImage)")
        #endif
        imageURLString = albumImage
        let name = json["user"]["full_name"].stringValue
        userName = name
        carouselMedia = json["carousel_media"].arrayValue
    }
    
    func processAlbumContents() -> [AlbumContent] {
        var albumImages = [AlbumContent]()
        if let imagesArray = carouselMedia {
            for subJson in imagesArray {
                var contentString = ""
                if subJson["images"].dictionary != nil {
                    contentString = subJson["images"]["low_resolution"]["url"].stringValue
                } else if subJson["videos"].dictionary != nil {
                    contentString = subJson["videos"]["low_resolution"]["url"].stringValue
                }
                let albumContent = AlbumContent(urlString: contentString)
                albumImages.append(albumContent)
            } // end of for loop
        } //end of if let
        return albumImages
    }
}

struct AlbumContent {
    var imageURLStr: String?
    
    init(urlString: String) {
        imageURLStr = urlString
    }
}
