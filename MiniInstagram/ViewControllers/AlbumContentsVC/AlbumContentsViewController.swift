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
            showMediaAbsentMessageOrRefreshTableView()
        }
    }
    
    private func showMediaAbsentMessageOrRefreshTableView() {
        guard let pictures = albumPictureURLs else {
            return
        }
        if pictures.count == 0 {
            let alert = UIAlertController(title: "No Likes", message: "There are no Liked pictures by you. Please like some to view them here :)", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } else {
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("album nav vc = \(String(describing: self.navigationController))")
        if let navVC = self.navigationController {
            if navVC.viewControllers.count > 1 {
                self.navigationController?.popViewController(animated: false)
            }
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
