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
    
    lazy var oauthswift = OAuth2Swift(
            consumerKey:    "e2728b29aa6345299785d2eebd1c9f27",
            consumerSecret: "ed8b307cc31b45d892e2263280225356",
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
            // or
            // accessTokenUrl: "https://api.instagram.com/oauth/access_token",
            // responseType:   "code"
        )

    let baseURLString = "https://api.instagram.com/v1/"
    
    //https://api.instagram.com/v1/media/{media-id}/likes
    func likeUnlikeMedia(mediaId: String, like: Bool, completionHandler:@escaping completionHandler) {
        let token = inquireToken()
        if token.characters.count > 1 {
            let finalURLString = baseURLString + "media/" + mediaId + "/likes?access_token=" + token
            if let url = URL(string: finalURLString) {
                if like {
                    Alamofire.request(url, method: .post).responseJSON(completionHandler: { (response) in
                        completionHandler(response.result.value)
                    })
                } else {
                    Alamofire.request(url, method: .delete).responseJSON(completionHandler: { (response) in
                        completionHandler(response.result.value)
                    })
                }
            }
        }
    }
    
    private func inquireToken() -> String {
        if let token = KeychainSwift().get(Constants.accessToken) {
            return token
        } else {
            return ""
        }
    }
    
    func fetchMedia(completionHandler: @escaping completionHandler) {
        let token = inquireToken()
        let finalURLString = baseURLString + "users/self/media/recent/?access_token=" + "\(String(describing: token))"
        print("finalURLString = \(finalURLString)")
        //https://api.instagram.com/v1/users/self/media/recent/?access_token=6696627282.e2728b2.d635d412d63b4b2f95f44296262108aa

        if let url = URL(string: finalURLString) {
            Alamofire.request(url).validate().responseJSON(completionHandler: { (response) in
                completionHandler(response.result.value)
            })
        }
    }
    
    func fetchUserLikes(completionHandler: @escaping completionHandler) {
        let token = inquireToken()
        //https://api.instagram.com/v1/users/self/media/liked?access_token=6696627282.e2728b2.d635d412d63b4b2f95f44296262108aa
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


extension APIProcessor {
    
    //https://www.instagram.com/oauth/authorize/?client_id=e2728b29aa6345299785d2eebd1c9f27&redirect_uri=https://www.23andme.com/&response_type=token&scope=likes+basic+public_content&state=R1prYujhoHphUIlnSy2h
    
    // MARK: Instagram
    func doOAuthInstagram(_ oauthswift: OAuth2Swift, completionHandler: @escaping completionHandler){
        let state = generateState(withLength: 20)
        
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "https://www.23andme.com/")!, scope: "likes+basic+public_content", state:state,
            success: {[unowned self] credential, response, parameters in
                //reset accessToken
                KeychainSwift().delete(Constants.accessToken)
                KeychainSwift().set("\(oauthswift.client.credential.oauthToken)", forKey: Constants.accessToken, withAccess: .accessibleWhenUnlocked)
                print("response = \(String(describing: response))")
                print("credential = \(String(describing: credential))")
                print("parameters = \(String(describing: parameters))")
                completionHandler(parameters)
                self.getUserInfoInstagram(oauthswift)
            },
            failure: { error in
                print(error.description)
        })
    }
    
    //    https://api.instagram.com/v1/users/self/?access_token=ACCESS-TOKEN
    
    func getUserInfoInstagram(_ oauthswift: OAuth2Swift) {
        var url = ""
        if let token = KeychainSwift().get(Constants.accessToken) {
            url = "https://api.instagram.com/v1/users/self/?access_token=\(token)"
            
        } else {
            url = "https://api.instagram.com/v1/users/self/?access_token=\(oauthswift.client.credential.oauthToken)"
        }
        
        //"https://api.instagram.com/v1/users/self/?access_token=6696627282.e2728b2.1c06860f5a5a4633a776c7eadc311c32"
        //        let url :String = "https://api.instagram.com/v1/users/self/?access_token=\(oauthswift.client.credential.oauthToken)"
        
        let parameters :Dictionary = Dictionary<String, AnyObject>()
        let _ = oauthswift.client.get(
            url, parameters: parameters,
            success: {(response) in
                let jsonDict = try? response.jsonObject()
                print("jsonDict UserInfo= \(jsonDict as Any)")
        },
            failure: { error in
                print(error)
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
