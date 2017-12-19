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
import SwiftyJSON

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
            if let loginVC = tabVC.viewControllers?.first as? LoginViewController {
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
    
    private func loginButtonPressed() {
        let oauthswift = APIProcessor.shared.oauthswift
        let _ = internalWebViewController.webView
        oauthswift.authorizeURLHandler = getURLHandler()
        APIProcessor.shared.doOAuthInstagram(oauthswift) {[unowned self] (response) in
            if let tokenResponse = response {
                let json = JSON(tokenResponse)
                let token = json["access_token"].stringValue
                if token.characters.count > 1 {
                    self.loginLogoutVC?.updateLoginLogoutButton()
                }
            }
        }
    }
    
    private func logOutButtonPressed() {
        KeychainSwift().delete(Constants.accessToken)
        loginLogoutVC?.updateLoginLogoutButton()
    }
    
    func loginLogoutButtonTapped() {
        if let token = KeychainSwift().get(Constants.accessToken) {
            if token.characters.count > 1 { //User is logined and Logout button is pressed
               logOutButtonPressed()
            }
        } else { //Login button is pressed
           loginButtonPressed()
        }
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
