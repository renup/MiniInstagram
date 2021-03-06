//
//  ImageHelper.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/16/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import AlamofireImage
import Alamofire

class ImageHelper: NSObject {
    var request: Request?
    var apiProcessor : APIProcessor { return .shared }
    static let shared: ImageHelper = ImageHelper()
    
    func reset() {
        request?.cancel()
    }
    
    func getPlaceHolderImage(inputURLStr: String) -> UIImage {
        var placeHolder = ""
        if inputURLStr.hasSuffix("mp4") {
            placeHolder = "videoPlaceHolder.png"
        } else {
            placeHolder = "placeHolder.png"
        }
        guard  let image = UIImage(named: placeHolder) else {
            return UIImage()
        }
        return image
    }
    
    /// Loads the image from cache or server
    ///
    /// - Parameter urlString: URL for the image
    func loadImage(urlString: String, completionHandler: @escaping ((_ image: Image?) -> Void)){
        
        if let cachedImage = apiProcessor.cachedImage(for: urlString) {
            completionHandler(cachedImage)
        } else {
            downloadImage(urlString: urlString, completionHandler: { (image) in
                if let downloadedImage = image {
                    completionHandler(downloadedImage)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
    
    /// Downloads the image from server
    ///
    /// - Parameter urlString: URL for image
    func downloadImage(urlString: String, completionHandler:@escaping ((_ image: Image?) -> Void)) {
        request = apiProcessor.fetchImageData(imageURLString: urlString, imageDownloadHandler: { (media) in
            if let photo = media {
                completionHandler(photo)
            } else {
                completionHandler(nil)
            }
        })
    }
    
}
