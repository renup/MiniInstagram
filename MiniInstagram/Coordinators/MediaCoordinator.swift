//
//  MediaCoordinator.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/12/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import OAuthSwift
//import Alamofire

protocol MediaCoordinatorDelegate: class {
    func needToRefreshAuthorizingWithInstagram()
}

class MediaCoordinator: NSObject {
    var oauthswift: OAuthSwift?
    var navigationVC: UINavigationController?
    var mediaViewController: MediaViewController?
    var value: MediaCoordinatorDelegate?
    weak var delegate: MediaCoordinatorDelegate? {
        set { value = newValue }
        get { return value }
    }
    
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
            APIProcessor.shared.fetchUserLikes(completionHandler: {[unowned self] (response) in
                
                if let jsonResponseDict = response as? NSDictionary {
                    if let valueDict = jsonResponseDict["meta"] as? NSDictionary {
                        if let errorType = valueDict["error_type"] as? String {
                            if errorType == " OAuthPermissionsException" || errorType == "OAuthParameterException"  {
                                //Just renew the auth token since it is expired
                                self.promptUserToReAuthorizeWithInstagram()
                                print("finally where i want ot be")
                            }
                        }
                    }
                    
                }
                
                
                
                
                
                print("Printing Likes json response in mediaCoordinator : \(String(describing: response))")
            })
        }
    }
    
    //In case the access_token is missing or if the permission to access media is invalid, we need to prompt user to reauthorize
    private func promptUserToReAuthorizeWithInstagram() {
       let alert = UIAlertController(title: "Authorization Required", message: "Please Re-Authorize with Instagram", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.delegate?.needToRefreshAuthorizingWithInstagram()
        }))
        mediaViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showMediaViewController() {
//        getMedia()
        getLikes()
        
        if let tabVC = navigationVC?.viewControllers.first as? InstagramTabBarController {
            
            if tabVC.selectedIndex == 1 {
                
            } else {
                tabVC.selectedIndex = 1
                if let mediaVC = tabVC.selectedViewController as? MediaViewController {
                    mediaViewController = mediaVC
                    mediaViewController?.delegate = self
                }
            }
            
        }
    }
}

extension MediaCoordinator: MediaViewControllerDelegate {
    func userLikedAMedia() {
        
    }
    
    
}
