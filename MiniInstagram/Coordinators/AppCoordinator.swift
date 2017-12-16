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
    
    init(_ navigationVC: UINavigationController) {
        self.navigationVC = navigationVC
    }
    
    func start() {
        guard let navVC = navigationVC else {
            return
        }
        
        if KeychainSwift().get(Constants.accessToken) != nil {
            let mediaCoordinatorInstance = MediaCoordinator(navVC)
            mediaCoordinator = mediaCoordinatorInstance
            mediaCoordinatorInstance.showMediaViewController()
        } else {
            let loginLogoutCoordinatorInstance = LoginLogoutCoordinator(navVC)
            loginLogoutCoordinator = loginLogoutCoordinatorInstance
            loginLogoutCoordinatorInstance.showLoginVC()
        }
       
    }
}


