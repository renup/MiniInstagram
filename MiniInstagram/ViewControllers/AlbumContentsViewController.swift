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

class PictureCell: UITableViewCell {
    var imageHelper: ImageHelper { return .shared }
//    var imageHelper = ImageHelper()

    @IBOutlet weak var pictureImageView: UIImageView!
    
    fileprivate func configureCell(content: AlbumContent) {
        guard let urlStr = content.imageURLStr else {
            return
        }
        setPlaceholderImage(urlString: urlStr)
        imageHelper.reset()
  
        imageHelper.loadImage(urlString: urlStr, completionHandler: {[unowned self] (image) in
                if let receivedImage = image {
                    self.populateWithImage(image: receivedImage)
                }
            })
    }
    
    private func setPlaceholderImage(urlString: String) {
        var placeHolder = ""
        if urlString.hasSuffix("mp4") {
            placeHolder = "videoPlaceHolder.png"
        } else {
            placeHolder = "placeHolder.png"
        }
        // Assigns a placeholder image for the cell
        guard let placeholderImg = UIImage(named: placeHolder), let imgURL = URL(string: urlString) else {
            return
        }
        pictureImageView.af_setImage(withURL: imgURL, placeholderImage: placeholderImg)
    }
    
    private func populateWithImage(image: UIImage) {
        pictureImageView.image = image
    }
    
}

class AlbumContentsViewController: UITableViewController {
    
    var albumPictureURLs: [AlbumContent]? {
        didSet {
            tableView.reloadData()
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
