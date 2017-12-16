//
//  MediaCoordinator.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/12/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import OAuthSwift
import Alamofire

class MediaCoordinator: NSObject {
    var oauthswift: OAuthSwift?
    var navigationVC: UINavigationController?
    var mediaViewController: MediaViewController?
    
    init(_ navigationVC: UINavigationController) {
        self.navigationVC = navigationVC
    }
    
    func getMedia() {
        DispatchQueue.global(qos: .utility).async {
            APIProcessor.shared.fetchMedia(completionHandler: { (response) in
                print("Printing json response in mediaCoordinator : \(String(describing: response))")
            })
        }
    }
    
    func getLikes() {
        DispatchQueue.global(qos: .utility).async {
            APIProcessor.shared.fetchUserLikes(completionHandler: { (response) in
                print("Printing Likes json response in mediaCoordinator : \(String(describing: response))")
            })
        }
    }
    
    func showMediaViewController() {
//        getMedia()
        getLikes()
        if let tabVC = navigationVC?.viewControllers.first as? InstagramTabBarController {
            tabVC.selectedIndex = 1
            if let mediaVC = tabVC.selectedViewController as? MediaViewController {
                mediaViewController = mediaVC
                mediaViewController?.delegate = self
            }
        }
    }
}

extension MediaCoordinator: MediaViewControllerDelegate {
    func userLikedAMedia() {
        
    }
    
    
}
