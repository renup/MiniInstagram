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
        request = apiProcessor.fetchImageData(imageURLString: urlString, imageDownloadHandler: { (storeImage) in
            if let restaurantImage = storeImage {
                completionHandler(restaurantImage)
            } else {
                completionHandler(nil)
            }
        })
    }
    
}
