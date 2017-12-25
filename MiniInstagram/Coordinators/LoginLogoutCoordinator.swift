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
        DispatchQueue.main.async {[unowned self] in
            // First we should delete the oAuth token from keychain
            KeychainSwift().delete(Constants.accessToken)
            
            //Also we should remove the cookie from the browser so that user is asked to login again
            let cookieJar : HTTPCookieStorage = HTTPCookieStorage.shared
            for cookie in cookieJar.cookies! as [HTTPCookie]{
                NSLog("cookie.domain = %@", cookie.domain)
                
                if cookie.domain == "www.instagram.com" ||
                    cookie.domain == "api.instagram.com"{
                    
                    cookieJar.deleteCookie(cookie)
                }
            }

            
            self.loginLogoutVC?.updateLoginLogoutButton()
        }
    }
    
    func loginLogoutButtonTapped() {
        if let _ = APIProcessor.shared.inquireToken() {
          //User is logined and Logout button is pressed
           logOutButtonPressed()
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
