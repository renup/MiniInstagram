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
        let storyboard = UIStoryboard.init(name: "Media", bundle: nil)
        if let mediaVC = storyboard.instantiateViewController(withIdentifier: "MediaViewController") as? MediaViewController {
            mediaViewController = mediaVC
            mediaViewController?.delegate = self
            navigationVC?.pushViewController(mediaVC, animated: false)
        }
    }
}

extension MediaCoordinator: MediaViewControllerDelegate {
    func userLikedAMedia() {
        
    }
    
    
}
