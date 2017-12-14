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
    var oauthswift: OAuthSwift?
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
        let _ = internalWebViewController.webView

        if let loginVC = navigationVC?.viewControllers.first as? LoginViewController {
            loginLogoutVC = loginVC
            loginLogoutVC?.delegate = self
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
    
    private func createAuthorizeRequest() -> OAuth2Swift {
        let oauthswift = OAuth2Swift(
            consumerKey:    "e2728b29aa6345299785d2eebd1c9f27",
            consumerSecret: "ed8b307cc31b45d892e2263280225356",
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
            // or
            // accessTokenUrl: "https://api.instagram.com/oauth/access_token",
            // responseType:   "code"
        )
        oauthswift.authorizeURLHandler = getURLHandler()
        
        self.oauthswift = oauthswift
        return oauthswift
    }
    
    // MARK: Instagram
    func doOAuthInstagram(){
        let oauthswift = createAuthorizeRequest()
        
        let state = generateState(withLength: 20)
        
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "https://www.23andme.com/")!, scope: "likes+basic", state:state,
            success: {[unowned self] credential, response, parameters in
                //self.testInstagram(oauthswift)
                self.getUserInfoInstagram(oauthswift)
                KeychainSwift().set("\(oauthswift.client.credential.oauthToken)", forKey: Constants.accessToken, withAccess: .accessibleWhenUnlocked)
                print("response = \(String(describing: response))")
                print("credential = \(String(describing: credential))")
                print("parameters = \(String(describing: parameters))")
            },
            failure: { error in
                
                print(error.description)
        })
    }
    
    //    https://api.instagram.com/v1/users/self/?access_token=ACCESS-TOKEN
    
    func getUserInfoInstagram(_ oauthswift: OAuth2Swift) {
        var url = ""
        if let token = KeychainSwift().get(Constants.accessToken) {
            url = "https://api.instagram.com/v1/users/self/?access_token=\(token)"
            
        } else {
            url = "https://api.instagram.com/v1/users/self/?access_token=\(oauthswift.client.credential.oauthToken)"
        }
        
        //"https://api.instagram.com/v1/users/self/?access_token=6696627282.e2728b2.1c06860f5a5a4633a776c7eadc311c32"
        //        let url :String = "https://api.instagram.com/v1/users/self/?access_token=\(oauthswift.client.credential.oauthToken)"
        
        let parameters :Dictionary = Dictionary<String, AnyObject>()
        let _ = oauthswift.client.get(
            url, parameters: parameters,
            success: { response in
                let jsonDict = try? response.jsonObject()
                print("jsonDict UserInfo= \(jsonDict as Any)")
        },
            failure: { error in
                if oauthswift.client.credential.isTokenExpired() {
                    oauthswift.startAuthorizedRequest("https://api.instagram.com/oauth/authorize", method: OAuthSwiftHTTPRequest.Method.GET, parameters: parameters, success: { (resoponse) in
                        print("response = \(String(describing: resoponse))")
                    }, failure: { (error) in
                        print("error in renewing token = \(String(describing: error))")
                    })
                }
                print(error)
        }
        )
    }
    
    func testInstagram(_ oauthswift: OAuth2Swift) {
        let url :String = "https://api.instagram.com/v1/users/6696627282/?access_token=\(oauthswift.client.credential.oauthToken)"
        let parameters :Dictionary = Dictionary<String, AnyObject>()
        let _ = oauthswift.client.get(
            url, parameters: parameters,
            success: { response in
                let jsonDict = try? response.jsonObject()
                print("jsonDict = \(jsonDict as Any)")
        },
            failure: { error in
                print(error)
        })
    }
    
    func loginLogoutButtonTapped() {
        doOAuthInstagram()
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
