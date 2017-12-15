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


class APIProcessor: NSObject {
    let baseURLString = "https://api.instagram.com/v1/"
    let accessToken = KeychainSwift().get(Constants.accessToken)
    
    func fetchMedia() {
        let finalURLString = baseURLString + "users/self/?access_token=" + "\(String(describing: accessToken))"
//        Alamofire.
    }
}
