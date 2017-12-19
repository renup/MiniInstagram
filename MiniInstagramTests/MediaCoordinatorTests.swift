//
//  MediaCoordinatorTests.swift
//  MiniInstagramTests
//
//  Created by Renu Punjabi on 12/18/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

//No such module issues with quick nimble mockingjay
//https://github.com/Quick/Quick/issues/731

import Quick
import Nimble
import Mockingjay

@testable import MiniInstagram

class MediaCoordinatorTests: QuickSpec {

    override func spec() {
        super.spec()
        
        describe("MediaCoordinator") {
            let navigationVC = UINavigationController()
            var mediaCoordinator: MediaCoordinator!
            
            beforeEach {
                mediaCoordinator = MediaCoordinator(navigationVC)
            }
            
            describe("APICalls") {
                var response: [Media]?
                
                context("FetchMedia") {
                    beforeEach {
                        let _ = self.stub(urlString: "https://api.instagram.com/v1/users/self/media/recent/?access_token=6696627282.e2728b2.d635d412d63b4b2f95f44296262108aa", jsonFileName: "MediaResponse")
                        
                        mediaCoordinator.getMedia()
                    }
                }
            }
        }
        
    }
}
