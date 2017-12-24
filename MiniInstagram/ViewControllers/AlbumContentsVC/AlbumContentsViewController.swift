//
//  AlbumContentsViewController.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/16/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class AlbumContentsViewController: UITableViewController {
    
    var albumPictureURLs: [AlbumContent]? {
        didSet {
            showMediaAbsentMessage()
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navVC = self.navigationController {
            if navVC.viewControllers.count > 1 {
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    private func showMediaAbsentMessage() {
        if albumPictureURLs == nil || (albumPictureURLs?.count)! < 1 {
            self.showErrorMessageAlert(title: "No Likes", message: "Something went wrong. Please make sure you are logged in, have internet connectivity or You've liked some media")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let pictures = albumPictureURLs {
            return pictures.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "picture") as! PictureCell
        
        if let pictures = albumPictureURLs {
            cell.configureCell(content: pictures[indexPath.row])
        }
        return cell
    }
    
}
