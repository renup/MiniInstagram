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
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("album nav vc = \(String(describing: self.navigationController))")
        self.navigationController?.popToRootViewController(animated: true)
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
