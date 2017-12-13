//
//  AppCoordinator.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/12/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import UIKit

class AppCoordinator: NSObject {
    
    var navigationVC: UINavigationController?
    
    init(_ navigationVC: UINavigationController) {
        self.navigationVC = navigationVC
    }
    
    func start() {
        guard navigationVC != nil else {
            return
        }
        let loginLogoutCoordinator = LoginLogoutCoordinator(navigationVC!)
        loginLogoutCoordinator.showLoginVC()
    }
    
}
