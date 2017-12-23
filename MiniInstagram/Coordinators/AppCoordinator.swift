//
//  AppCoordinator.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/12/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift

class AppCoordinator: NSObject {

    var navigationVC: UINavigationController!
    var loginLogoutCoordinator: LoginLogoutCoordinator?
    var mediaCoordinator: MediaCoordinator?
    var tabVC: InstagramTabBarController?
    
    init(_ navigationVC: UINavigationController) {
        self.navigationVC = navigationVC
    }
    
    func start() {
        guard let tabVC = navigationVC?.viewControllers.first as? InstagramTabBarController else {
            return
        }
        self.tabVC = tabVC
        self.tabVC?.instagramDelegate = self
        
        if APIProcessor.shared.isUserLoggedIn() {
            tabVC.selectedIndex = 1
            initiateMediaCoordinator(navigationVC)
        } else {
            tabVC.selectedIndex = 0
            initiateLoginCoordinator(navigationVC)
        }
    }
    
    fileprivate func initiateMediaCoordinator(_ navVC: UINavigationController) {
        if mediaCoordinator == nil {
            let mediaCoordinatorInstance = MediaCoordinator(navVC)
            mediaCoordinator = mediaCoordinatorInstance
            mediaCoordinator?.delegate = self
        }
        mediaCoordinator?.showMediaViewController()
    }
    
    fileprivate func initiateLoginCoordinator(_ navVC: UINavigationController) {
        if loginLogoutCoordinator == nil {
            let loginLogoutCoordinatorInstance = LoginLogoutCoordinator(navVC)
            loginLogoutCoordinator = loginLogoutCoordinatorInstance
        }
        loginLogoutCoordinator?.showLoginVC()
    }
}

extension AppCoordinator: MediaCoordinatorDelegate {
    func needToRefreshAuthorizingWithInstagram() {
        initiateLoginCoordinator(navigationVC)
    }
}

extension AppCoordinator: InstagramTabBarControllerDelegate {
    func userChangedTab(item: UITabBarItem) {
        if item.title == "Media" {
            tabVC?.selectedIndex = 1
            initiateMediaCoordinator(navigationVC)
        } else if item.title == "Likes" {
            tabVC?.selectedIndex = 2
            initiateMediaCoordinator(navigationVC)
        } else {
            initiateLoginCoordinator(navigationVC)
        }
    }
    
    
}


