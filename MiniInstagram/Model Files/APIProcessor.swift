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

typealias completionHandler = ((_ response: Any?) -> Void)


class APIProcessor: NSObject {
    static let shared: APIProcessor = APIProcessor()

    let baseURLString = "https://api.instagram.com/v1/"
    let accessToken = KeychainSwift().get(Constants.accessToken)
    
    //https://api.instagram.com/v1/users/self/media/recent/?access_token=6696627282.e2728b2.1c06860f5a5a4633a776c7eadc311c31
    func fetchMedia(completionHandler: @escaping completionHandler) {
        if let token = accessToken {
            let finalURLString = baseURLString + "users/self/media/recent/?access_token=" + "\(String(describing: token))"
            print("finalURLString = \(finalURLString)")
            if let url = URL(string: finalURLString) {
                Alamofire.request(url).validate().responseJSON(completionHandler: { (response) in
                    
//                    print("media response: \(response)")
                    completionHandler(response.result.value)
                })
            }
        }
    }
    
    func fetchUserLikes(completionHandler: @escaping completionHandler) {
        guard let token = accessToken else {
            return
        }
        
        //https://api.instagram.com/v1/users/self/media/liked?access_token=6696627282.e2728b2.1c06860f5a5a4633a776c7eadc311c31
        let finalURLString = baseURLString + "users/self/media/liked?" + "\(String(describing: token))"
        print("finalURLString = \(finalURLString)")

        if let url = URL(string: finalURLString) {
            Alamofire.request(url).responseJSON(completionHandler:{(response) in
                print("token - \(token)")
                switch response.result {
                case .success:
                    print("Validation Successful")
                case .failure(let error):
                    print("error in likes call - \(error)")
                }
                
                
//                print("media liked by user - \(String(describing: response.result.value))")
                completionHandler(response.result.value)
            })
        }
    }
        
}
