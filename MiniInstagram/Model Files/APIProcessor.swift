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
    
    func fetchMedia(completionHandler: @escaping completionHandler) {
        if let token = accessToken {
            let finalURLString = baseURLString + "users/self/media/recent/?access_token=" + "\(String(describing: token))"
            if let url = URL(string: finalURLString) {
                Alamofire.request(url).validate().responseJSON(completionHandler: { (response) in
                    
                    print("media response: \(response)")
                    completionHandler(response.result.value)
                })
                
            }
        }
        }
        
}
