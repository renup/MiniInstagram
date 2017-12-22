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
            consumerKey:    "e2728b29aa6345299785d2eebd1c9f27",
            consumerSecret: "ed8b307cc31b45d892e2263280225356",
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
        )

    let baseURLString = "https://api.instagram.com/v1/"
    
    /// This method is called to like/unlike a media based on bool value passed
    ///
    /// - Parameters:
    ///   - mediaId: mediaID for media to be liked/unliked
    ///   - like: bool value to indicate where the media should be liked or disliked
    ///   - completionHandler: completion handler for liking/disliking
    func likeUnlikeMedia(mediaId: String, like: Bool, completionHandler:@escaping completionHandler) {
        let token = inquireToken()
        if token.characters.count > 1 {
            // Prepare base URL for liking/disliking the media
            let finalURLString = baseURLString + "media/" + mediaId + "/likes?access_token=" + token
            if let url = URL(string: finalURLString) {
                if like { // check bool flag to decide if media should be liked
                    Alamofire.request(url, method: .post).responseJSON(completionHandler: { (response) in
                        completionHandler(response.result.value)
                    })
                } else {// check bool flag to decide if media should be disliked
                    Alamofire.request(url, method: .delete).responseJSON(completionHandler: { (response) in
                        completionHandler(response.result.value)
                    })
                }
            }
        }
    }
    
    /// Checks to see if oAuth token exists in keychain storage
    ///
    /// - Returns: returns the oAuth token or empty string
    private func inquireToken() -> String {
        if let token = KeychainSwift().get(Constants.accessToken) {
            return token
        } else {
            return ""
        }
    }
    
    /// Fetches media posted by current user
    ///
    /// - Parameter completionHandler: handles completion for network call
    func fetchMedia(completionHandler: @escaping completionHandler) {
        let token = inquireToken()
        let finalURLString = baseURLString + "users/self/media/recent/?access_token=" + "\(String(describing: token))"
        print("finalURLString = \(finalURLString)")

        //
        if let url = URL(string: finalURLString) {
            Alamofire.request(url).validate().responseJSON(completionHandler: { (response) in
                completionHandler(response.result.value)
            })
        }
    }
    
    func fetchUserLikes(completionHandler: @escaping completionHandler) {
        let token = inquireToken()

        let finalURLString = baseURLString + "users/self/media/liked?access_token=" + "\(String(describing: token))"
        #if debug
            print("finalURLString = \(finalURLString)")
            print("token = \(String(describing: token))")
        #endif
        // here with no validate() in alamofire request, we will receive error in response too
        if let url = URL(string: finalURLString) {
            Alamofire.request(url).validate().responseJSON(completionHandler:{(response) in
                completionHandler(response.result.value)
            })
        }
    }
}



// MARK: - This extension handle getting the oAuth Token
extension APIProcessor {
    
    
    func doOAuthInstagram(_ oauthswift: OAuth2Swift, completionHandler: @escaping completionHandler){
        let state = generateState(withLength: 20)
        
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "https://www.23andme.com/")!, scope: "likes+basic+public_content", state:state,
            success: {[unowned self] credential, response, parameters in
                //reset accessToken
                KeychainSwift().delete(Constants.accessToken)
                KeychainSwift().set("\(oauthswift.client.credential.oauthToken)", forKey: Constants.accessToken, withAccess: .accessibleWhenUnlocked)
                #if debug
                print("response = \(String(describing: response))")
                print("credential = \(String(describing: credential))")
                print("parameters = \(String(describing: parameters))")
                #endif
                    
                completionHandler(parameters)
                self.getUserInfoInstagram(oauthswift)
            },
            failure: { error in
                #if debug
                print(error.description)
                #endif
        })
    }
    
    
    /// Gets user's information from Instagram
    ///
    /// - Parameter oauthswift: oauth swift object with needed strings for getting token
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
    
    /// Fetches Images for a restaurant
    ///
    /// - Parameters:
    ///   - imageURLString: restaurant Image URL String
    ///   - imageDownloadHandler: Handler contains jsonResponse array and error
    /// - Returns: returns a UIImage object for the restaurant
    func fetchImageData(imageURLString: String, imageDownloadHandler: @escaping ((_ image: UIImage?) -> Void)) -> Request {
        //download image data using alamofire
        
        return Alamofire.request(imageURLString, method: .get).responseImage { (response) in
            if let image = response.result.value {
                imageDownloadHandler(image)
                self.cache(image, for: imageURLString)
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
