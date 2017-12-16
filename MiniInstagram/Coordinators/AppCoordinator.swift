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

    var navigationVC: UINavigationController?
    var loginLogoutCoordinator: LoginLogoutCoordinator?
    var mediaCoordinator: MediaCoordinator?
    var tabVC: InstagramTabBarController?
    
    init(_ navigationVC: UINavigationController) {
        self.navigationVC = navigationVC
    }
    
    func start() {
        tabVC?.instagramDelegate = self
        guard let navVC = navigationVC else {
            return
        }
        if KeychainSwift().get(Constants.accessToken) != nil {
            initiateMediaCoordinator(navVC)
        } else {
            initiateLoginCoordinator(navVC)
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
        initiateLoginCoordinator(navigationVC!)
    }
}

extension AppCoordinator: InstagramTabBarControllerDelegate {
    func userChangedTab(item: UITabBarItem) {
        initiateMediaCoordinator(navigationVC!)
    }
    
    
}


