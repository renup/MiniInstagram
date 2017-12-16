//
//  LoginLogoutCoordinator.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/12/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import UIKit
import KeychainSwift
import OAuthSwift
import Alamofire

class LoginLogoutCoordinator: NSObject, LoginViewControllerDelegate {
    
    var navigationVC: UINavigationController?
    var loginLogoutVC: LoginViewController?
    
    lazy var internalWebViewController: WebViewController = {
        let controller = WebViewController()
        controller.view = UIView(frame: UIScreen.main.bounds)
        controller.delegate = self
        controller.viewDidLoad() // allow WebViewController to use this ViewController as parent to be presented
        return controller
    }()
    

    init(_ navigationVC: UINavigationController) {
        self.navigationVC = navigationVC
    }
    
    func showLoginVC() {
        if let tabVC = navigationVC?.viewControllers.first as? InstagramTabBarController {
            tabVC.selectedIndex = 0
            if let loginVC = tabVC.selectedViewController as? LoginViewController {
                loginLogoutVC = loginVC
                loginLogoutVC?.delegate = self
            }
        }
    }
    
    //MARK: private methods
    // MARK: handler
    func getURLHandler() -> OAuthSwiftURLHandlerType {
        if internalWebViewController.parent == nil {
            loginLogoutVC?.addChildViewController(internalWebViewController)
        }
        return internalWebViewController
    }
    
    func loginLogoutButtonTapped() {
       let oauthswift = APIProcessor.shared.oauthswift
        let _ = internalWebViewController.webView
        oauthswift.authorizeURLHandler = getURLHandler()
        APIProcessor.shared.doOAuthInstagram(oauthswift)
    }
}

extension LoginLogoutCoordinator: OAuthWebViewControllerDelegate {
    func oauthWebViewControllerDidPresent() {}
    func oauthWebViewControllerDidDismiss() {}
    func oauthWebViewControllerWillAppear() {}
    func oauthWebViewControllerDidAppear() {}
    func oauthWebViewControllerWillDisappear() {}
    func oauthWebViewControllerDidDisappear() {}
}
