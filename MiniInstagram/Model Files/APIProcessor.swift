//
//  APIProcessor.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/14/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift
import OAuthSwift
import SwiftyJSON
import AlamofireImage

typealias completionHandler = ((_ response: Any?) -> Void)

extension UInt64 {
    func megabytes() -> UInt64 {
        return self * 1024 * 1024
    }
}

class APIProcessor: NSObject {
    static let shared: APIProcessor = APIProcessor()
    
    // specifying cache size for managing the images
    let imageCache = AutoPurgingImageCache(
        memoryCapacity: UInt64(100).megabytes(),
        preferredMemoryUsageAfterPurge: UInt64(60).megabytes()
    )
    
    // create basic string values needed for Oauth to Instagram service
    lazy var oauthswift = OAuth2Swift(
            consumerKey:    Constants.consumerKey,
            consumerSecret: Constants.consumerSecret,
            authorizeUrl:   Constants.authorizeURL,
            responseType:   Constants.responseType
        )

    let baseURLString = "https://api.instagram.com/v1/"
    
    private func constructLikesUnlikesURL(id: String) -> String? {
        guard let token = inquireToken() else {
            return nil
        }
       return baseURLString + "media/" + id + "/likes?access_token=" + token
    }
    
    func likeMedia(mediaId: String, completionHandler: @escaping completionHandler) {
        guard let finalUrlString = constructLikesUnlikesURL(id: mediaId) else {
            completionHandler(nil)
            return
        }
        Alamofire.request(finalUrlString, method: .post).validate().responseJSON(completionHandler: { (response) in
            completionHandler(response.result.value)
        })
    }
    
    func unlikeMedia(mediaId: String, completionHandler: @escaping completionHandler) {
        guard let finalUrlString = constructLikesUnlikesURL(id: mediaId) else {
            completionHandler(nil)
            return
        }
        Alamofire.request(finalUrlString, method: .delete).validate().responseJSON(completionHandler: { (response) in
            completionHandler(response.result.value)
        })
    }
    
    /// Checks to see if oAuth token exists in keychain storage
    ///
    /// - Returns: returns the oAuth token or empty string
    func inquireToken() -> String? {
        return KeychainSwift().get(Constants.accessToken)
    }
    
    /// Fetches media posted by current user
    ///
    /// - Parameter completionHandler: handles completion for network call
    func fetchMedia(completionHandler: @escaping completionHandler) {
        guard let token = inquireToken() else {//if no token, don't make api call
            completionHandler(nil)
            return
        }
        let finalURLString = baseURLString + "users/self/media/recent/?access_token=" + "\(token)"
        #if DEBUG
            print("finalURLString = \(finalURLString)")
        #endif
        Alamofire.request(finalURLString).validate().responseJSON(completionHandler: { (response) in
                completionHandler(response.result.value)
        })
    }
    
    func fetchUserLikes(completionHandler: @escaping completionHandler) {
        guard let token = inquireToken() else {//if no token, don't make api call
            completionHandler(nil)
            return
        }
        let finalURLString = baseURLString + "users/self/media/liked?access_token=" + "\(token)"
        #if DEBUG
            print("finalURLString = \(finalURLString)")
            print("token = \(String(describing: token))")
        #endif
        
        Alamofire.request(finalURLString).validate().responseJSON(completionHandler:{(response) in
                completionHandler(response.result.value)
        })
    }
}


// MARK: - This extension handle getting the oAuth Token
extension APIProcessor {
    
    func doOAuthInstagram(_ oauthswift: OAuth2Swift, completionHandler: @escaping completionHandler){
        let state = generateState(withLength: 20)
        
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "https://www.23andme.com/")!, scope: "likes+basic+public_content", state:state,
            success: {credential, response, parameters in
                //reset accessToken
                KeychainSwift().delete(Constants.accessToken)
                KeychainSwift().set("\(oauthswift.client.credential.oauthToken)", forKey: Constants.accessToken, withAccess: .accessibleWhenUnlocked)
                #if DEBUG
                print("response = \(String(describing: response))")
                print("credential = \(String(describing: credential))")
                print("parameters = \(String(describing: parameters))")
                #endif
                    
                completionHandler(parameters)
            },
            failure: { error in
                #if DEBUG
                print(error.description)
                #endif
        })
    }
    
    
    /// Gets user's information from Instagram
    ///
    /// - Parameter oauthswift: oauth swift object with needed strings for getting token
    
    //TODO: take out this method
    func getUserInfoInstagram(_ oauthswift: OAuth2Swift) {
        var url = ""
        if let token = KeychainSwift().get(Constants.accessToken) {
            url = "https://api.instagram.com/v1/users/self/?access_token=\(token)"
            
        } else {
            url = "https://api.instagram.com/v1/users/self/?access_token=\(oauthswift.client.credential.oauthToken)"
        }
        
        let parameters :Dictionary = Dictionary<String, AnyObject>()
        let _ = oauthswift.client.get(
            url, parameters: parameters,
            success: {(response) in
                let jsonDict = try? response.jsonObject()
                #if debug
                print("jsonDict UserInfo= \(jsonDict as Any)")
                #endif

        },
            failure: { error in
                #if debug
                print(error)
                #endif
        }
        )
    }
}

extension APIProcessor {
    
    /// Fetches Images for a Media
    ///
    /// - Parameters:
    ///   - imageURLString: Media Image URL String
    ///   - imageDownloadHandler: Handler contains jsonResponse array and error
    /// - Returns: returns a UIImage object for the Media
    func fetchImageData(imageURLString: String, imageDownloadHandler: @escaping ((_ image: UIImage?) -> Void)) -> Request {
        //download image data using alamofire
        
        return Alamofire.request(imageURLString, method: .get).responseImage { (response) in
            if let image = response.result.value {
                self.cache(image, for: imageURLString)
                imageDownloadHandler(image)
            } else {
                imageDownloadHandler(nil)
            }
        }
    }
    
    /// Saves an image to the memory cache
    ///
    /// - Parameters:
    ///   - image: Image object to be saved to cache
    ///   - url: URL string to be associated with the image being saved to cache
    func cache(_ image: Image, for url: String) {
        imageCache.add(image, withIdentifier: url)
    }
    
    
    /// Returns cached image for the URL string provided
    ///
    /// - Parameter url: url string associated with the cached image
    /// - Returns: returns an Image object from the cache
    func cachedImage(for url: String) -> Image? {
        return imageCache.image(withIdentifier: url)
    }

}
