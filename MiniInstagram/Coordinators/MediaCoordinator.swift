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
    
    func showMediaViewController() {
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
