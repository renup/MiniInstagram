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

typealias completionHandler = ((_ response: Any?) -> Void)

class APIProcessor: NSObject {
    static let shared: APIProcessor = APIProcessor()
    
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
    let accessToken = KeychainSwift().get(Constants.accessToken)
    
    //https://api.instagram.com/v1/users/self/media/recent/?access_token=6696627282.e2728b2.1c06860f5a5a4633a776c7eadc311c31
    func fetchMedia(completionHandler: @escaping completionHandler) {
        if let token = accessToken {
            let finalURLString = baseURLString + "users/self/media/recent/?access_token=" + "\(String(describing: token))"
            print("finalURLString = \(finalURLString)")
//            if let url = URL(string: finalURLString) {
            
//               let _ = APIProcessor.shared.oauthswift.client.get(finalURLString, success: { (response) in
//                    completionHandler(response, nil)
//                }, failure: { (error) in
//                    completionHandler(nil, error)
//                })
            
//                Alamofire.request(url).validate().responseJSON(completionHandler: { (response) in
//
////                    print("media response: \(response)")
//                    completionHandler(response.result.value)
//                })
            }
        //}
    }
    
    func fetchUserLikes(completionHandler: @escaping completionHandler) {
        guard let token = accessToken else {
            return
        }
        
        //https://api.instagram.com/v1/users/self/media/liked?access_token=6696627282.e2728b2.1c06860f5a5a4633a776c7eadc311c31
        let finalURLString = baseURLString + "users/self/media/liked?" + "\(String(describing: token))"
        #if debug
        print("finalURLString = \(finalURLString)")
        #endif

        if let url = URL(string: finalURLString) {
        
//        let _ = APIProcessor.shared.oauthswift.client.get(finalURLString, success: { (response) in
//            completionHandler(response, nil)
//        }, failure: { (error) in
//            print("error: \(error.localizedDescription)")
//            completionHandler(error, error)
//        })
        
            Alamofire.request(url).responseJSON(completionHandler:{(response) in
                
                if let jsonResponseDict = response.result.value as? NSDictionary {
                    if let valueDict = jsonResponseDict["meta"] as? NSDictionary {
                        if let errorType = valueDict["error_type"] as? String {
                            if errorType == " OAuthPermissionsException" || errorType == "OAuthParameterException"  {
                                //Just renew the auth token since it is expired
                                print("finally where i want ot be")
                            }
                        }
                    }
                    
                }
                
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                case .failure(let error):
                    print("error in likes call - \(error)")
                }

                completionHandler(response.result.value)
            })
        }
    
}
    //}
}


extension APIProcessor {
//    func createAuthorizeRequest() -> OAuth2Swift {
//        let oauthswift = OAuth2Swift(
//            consumerKey:    "e2728b29aa6345299785d2eebd1c9f27",
//            consumerSecret: "ed8b307cc31b45d892e2263280225356",
//            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
//            responseType:   "token"
//            // or
//            // accessTokenUrl: "https://api.instagram.com/oauth/access_token",
//            // responseType:   "code"
//        )
//        oAuthswift = oauthswift
//        return oauthswift
//    }
    // MARK: Instagram
    func doOAuthInstagram(_ oauthswift: OAuth2Swift){
        let state = generateState(withLength: 20)
        
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "https://www.23andme.com/")!, scope: "likes+basic+public_content", state:state,
            success: {[unowned self] credential, response, parameters in
                //self.testInstagram(oauthswift)
                self.getUserInfoInstagram(oauthswift)
                KeychainSwift().set("\(oauthswift.client.credential.oauthToken)", forKey: Constants.accessToken, withAccess: .accessibleWhenUnlocked)
                print("response = \(String(describing: response))")
                print("credential = \(String(describing: credential))")
                print("parameters = \(String(describing: parameters))")
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
            success: { response in
                let jsonDict = try? response.jsonObject()
                print("jsonDict UserInfo= \(jsonDict as Any)")
        },
            failure: { error in
                if oauthswift.client.credential.isTokenExpired() {
                    oauthswift.startAuthorizedRequest("https://api.instagram.com/oauth/authorize", method: OAuthSwiftHTTPRequest.Method.GET, parameters: parameters, success: { (resoponse) in
                        print("response = \(String(describing: resoponse))")
                    }, failure: { (error) in
                        print("error in renewing token = \(String(describing: error))")
                    })
                }
                print(error)
        }
        )
    }
    
    
}
