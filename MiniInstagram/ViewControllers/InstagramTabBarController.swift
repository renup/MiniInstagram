//
//  InstagramTabBarController.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/14/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import UIKit

protocol InstagramTabBarControllerDelegate: class {
    func userChangedTab(item: UITabBarItem)
}

class InstagramTabBarController: UITabBarController {
    var value: InstagramTabBarControllerDelegate?
    weak var instagramDelegate: InstagramTabBarControllerDelegate? {
        set { value = newValue }
        get { return value }
    }
    
    //MARK: Delegate methods
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        instagramDelegate?.userChangedTab(item: item)
    }
}
