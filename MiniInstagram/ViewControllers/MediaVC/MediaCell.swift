//
//  MediaCell.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/16/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
import Alamofire

class MediaCell: UITableViewCell {
    
    var request: Request?
    var apiProcessor : APIProcessor { return .shared }
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var likeUnlikeButton: UIButton!
    
    func configureCell(media: Media) {
        setPlaceholderImage(urlString: media.imageURLString)
        reset()
        if let urlStr = media.imageURLString {
            loadImage(urlString: urlStr)
        }
    }
    
    private func setPlaceholderImage(urlString: String?) {
        // Assigns a placeholder image for the cell
        guard let placeholderImage = UIImage(named: "placeHolder.png"), let urlStr = urlString, let imgURL = URL(string: urlStr) else {
            return
        }
        mediaImageView.af_setImage(withURL: imgURL, placeholderImage: placeholderImage)
    }
    
    private func reset() {
        request?.cancel()
    }
    
    /// Loads the image from cache or server
    ///
    /// - Parameter urlString: URL for the image
    private func loadImage(urlString: String) {
        
        if let cachedImage = apiProcessor.cachedImage(for: urlString) {
            populateWithImage(image: cachedImage)
        } else {
            downloadImage(urlString: urlString)
        }
    }
    
    /// Downloads the image from server
    ///
    /// - Parameter urlString: URL for image
    private func downloadImage(urlString: String) {
        request = apiProcessor.fetchImageData(imageURLString: urlString, imageDownloadHandler: {[unowned self] (storeImage) in
            if let restaurantImage = storeImage {
                self.populateWithImage(image: restaurantImage)
            }
        })
    }
    
    /// Populates the coverImageview with the image provided
    ///
    /// - Parameter image: image Object of type UIImage
    private func populateWithImage(image: UIImage) {
        mediaImageView.image = image
    }
    
    
    @IBAction func likeUnlikeButtonClicked(_ sender: Any) {
    }
    
    
}
