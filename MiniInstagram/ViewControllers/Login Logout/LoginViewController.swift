//
//  LoginViewController.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/10/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import UIKit
import OAuthSwift

protocol LoginViewControllerDelegate: class {
    func loginLogoutButtonTapped()
}

class LoginViewController: OAuthViewController {
    
    @IBOutlet weak var loginLogoutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    var value: LoginViewControllerDelegate?
    
    weak var delegate: LoginViewControllerDelegate? {
        get { return value }
        set { value = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginLogoutButtonClicked(_ sender: Any) {
        delegate?.loginLogoutButtonTapped()
    }
   
}




