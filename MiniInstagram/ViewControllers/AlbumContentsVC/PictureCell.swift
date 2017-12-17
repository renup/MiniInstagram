//
//  PictureCell.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/17/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import UIKit

class PictureCell: UITableViewCell {
    var imageHelper: ImageHelper { return .shared }
    @IBOutlet weak var pictureImageView: UIImageView!
    
    func configureCell(content: AlbumContent) {
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
        // Assigns a placeholder image for the cell
        guard let imgURL = URL(string: urlString) else {
            return
        }
        pictureImageView.af_setImage(withURL: imgURL, placeholderImage: imageHelper.getPlaceHolderImage(inputURLStr: urlString))
    }
    
    private func populateWithImage(image: UIImage) {
        pictureImageView.image = image
    }
    
    
    @IBAction func likeButtonClicked(_ sender: Any) {
    }
    
    @IBAction func unlikeButtonClicked(_ sender: Any) {
    }
    
}
