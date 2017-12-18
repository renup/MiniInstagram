//
//  MediaCoordinator.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/12/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import OAuthSwift
import SwiftyJSON

protocol MediaCoordinatorDelegate: class {
    func needToRefreshAuthorizingWithInstagram()
}

class MediaCoordinator: NSObject {
    var oauthswift: OAuthSwift?
    var navigationVC: UINavigationController?
    var mediaViewController: MediaViewController?
    var value: MediaCoordinatorDelegate?
    var albumContentViewController: AlbumContentsViewController?
    var tabViewController: InstagramTabBarController?
    
    weak var delegate: MediaCoordinatorDelegate? {
        set { value = newValue }
        get { return value }
    }
    
    init(_ navigationVC: UINavigationController) {
        self.navigationVC = navigationVC
    }
    
    
    
    func showMediaViewController() {
        
        if let tabVC = navigationVC?.viewControllers.first as? InstagramTabBarController {
            tabViewController = tabVC
            if tabVC.selectedIndex == 1 {
                guard let navVC = tabVC.viewControllers![1] as? UINavigationController else {
                    return
                }
                tabViewController?.selectedIndex = 1
                if let mediaVC = navVC.viewControllers.first as? MediaViewController {
                    mediaViewController = mediaVC
                }
                mediaViewController?.delegate = self
                getMedia()
            } else  if tabVC.selectedIndex == 2 {
                guard let navVC = tabVC.viewControllers?.last as? UINavigationController else {
                    return
                }
                tabViewController?.selectedIndex = 2
                if let albumContentsVC = navVC.viewControllers.first as? AlbumContentsViewController {
                    albumContentViewController = albumContentsVC
                }
                getLikes()
            } //end of else if
        }
    }
    
    func getMedia() {
        DispatchQueue.global(qos: .utility).async {
            APIProcessor.shared.fetchMedia(completionHandler: {[unowned self] (response) in
                if response != nil {
                    let json = JSON(response!)
                    self.mediaViewController?.mediaAlbum = self.createMediaObjects(json: json)
                }
                
                print("Printing media json response in mediaCoordinator : \(String(describing: response))")
            })
        }
    }
    
    private func createMediaObjects(json: JSON) -> [Media] {
        var albumArray = [Media]()
        let array = json["data"] //albums array
        for item in array { //
            let album = Media(mediaAlbum: item)
            albumArray.append(album)
        }
        return albumArray
    }
    
    fileprivate func processAlbumContents(album: Media) -> [AlbumContent] {
        var albumImages = [AlbumContent]()
        if let imagesArray = album.carouselMedia {
            for subJson in imagesArray {
                var contentString = ""
                if subJson["images"].dictionary != nil {
                    contentString = subJson["images"]["low_resolution"]["url"].stringValue
                } else if subJson["videos"].dictionary != nil {
                    contentString = subJson["videos"]["low_resolution"]["url"].stringValue
                }
                let albumContent = AlbumContent(urlString: contentString)
                albumImages.append(albumContent)
            } // end of for loop
        } //end of if let
        return albumImages
    }
    
    func getLikes() {
        DispatchQueue.global(qos: .utility).async {            APIProcessor.shared.fetchUserLikes(completionHandler: {[unowned self] (response) in
                
                let json = JSON(response!)
                let errorType = json["meta"]["error_type"]
                
                if (errorType.dictionaryObject != nil) {
                    if errorType == "OAuthPermissionsException" || errorType == "OAuthParameterException" || errorType == "OAuthAccessTokenException" {
                        //Just renew the auth token since it is expired
                        self.promptUserToReAuthorizeWithInstagram()
                    }
                } else {
                    var likedPhotosURLStringArray = [AlbumContent]()
                    let array = self.createMediaObjects(json: json)
                    for item in array {
                        let likedPhotos = self.processAlbumContents(album: item)
                        likedPhotosURLStringArray.append(contentsOf: likedPhotos)
                    }
                    
                    self.albumContentViewController?.albumPictureURLs = likedPhotosURLStringArray
                }
                
                
                
                print("Printing Likes json response in mediaCoordinator : \(String(describing: response))")
            })
        }
    }
    
    //In case the access_token is missing or if the permission to access media is invalid, we need to prompt user to reauthorize
    private func promptUserToReAuthorizeWithInstagram() {
       let alert = UIAlertController(title: "Authorization Required", message: "Please Re-Authorize with Instagram", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.delegate?.needToRefreshAuthorizingWithInstagram()
        }))
        mediaViewController?.present(alert, animated: true, completion: nil)
    }  
}

extension MediaCoordinator: MediaViewControllerDelegate {
    func userClickedLikeUnlikeButton(media: Media) {
        <#code#>
    }
    
    
    func userSelectedAnAlbum(media: Media) {
        let albumPictureURLs = processAlbumContents(album: media)
    
        if let navVC = tabViewController?.viewControllers![1] as? UINavigationController {
            if albumContentViewController == nil {
                guard let albumContentVC = AlbumContentsViewController.instantiateControllerFromStoryboard(name: "Instagram", identifier: "AlbumContentsViewController") as? AlbumContentsViewController else {
                    return
                }
                albumContentViewController = albumContentVC
            }
            albumContentViewController?.albumPictureURLs = albumPictureURLs
            navVC.pushViewController(albumContentViewController!, animated: true)
        }
    }
}
