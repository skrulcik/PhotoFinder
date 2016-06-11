//
//  ImageResult.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/4/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

import Foundation
import UIKit

/**

## Image Result

Wrapper class for
Encapsulates a single JSON from the Google Image Search API "results" array,
allowing object-like access from other files.

[API-Defined Fields](https://developers.google.com/image-search/v1/jsondevguide#results_guaranteed)

*/
class ImageResult: NSObject {
    let imageTitle: String
    let snippet: String
    let link: String
    let width: Int
    let height: Int
    let thumbnailLink: String
    var imageDescription: String {
        return "\(link)\n\(snippet)"
    }


    class func fromList(jsonList: [[String : AnyObject]]) -> [ImageResult] {
        var results = [ImageResult]()
        for rawJSON in jsonList {
            if let concreteObject = ImageResult(json: rawJSON) {
                results.append(concreteObject)
            }
        }
        return results
    }

    /**
    Attempts to create `ImageResult` object out of JSON Dictionary. 
    
    Guarantees proper object creation if all required keys are present. If any 
    required keys are missing, initialization fails.
    */
    init?(json: [String : AnyObject]) {
        if let imageTitle = json["title"] as? String,
        let snippet = json["snippet"] as? String,
        let link = json["link"] as? String,
        let rawImageData = json["image"] as? [String : AnyObject],
        let width = rawImageData["width"] as? Int,
        let height = rawImageData["height"] as? Int,
            let thumbnailLink = rawImageData["thumbnailLink"] as? String {
            self.imageTitle = imageTitle
            self.snippet = snippet
            self.link = link
            self.width = width
            self.height = height
            self.thumbnailLink = thumbnailLink
            super.init()
        } else {
            return nil
        }
    }
}

/**
Slight breach of MVC here, but this allows the model, which has access to
both the thumbnail and regular URL, populate images with increasing resolution.
Because theses methods are here, it is achieved without any other classes
poking around the JSON, which is the point of this class.
*/
extension ImageResult {
    /**
    Downloads full image (if necessary) and populates the given UIImageView
    Completion handler is only called on success
    */
    func populateViewWithImage(imageView: UIImageView, completion: (Void -> Void)? = nil) {
        populateViewFromURL(imageView, linkString: link, completion: completion)
    }
    /**
    Downloads thumbnail (if necessary) and populates the given UIImageView
    Completion handler is only called on success
    */
    func populateViewWithImageThumbnail(imageView: UIImageView, completion: (Void -> Void)? = nil) {
        populateViewFromURL(imageView, linkString: thumbnailLink, completion: completion)
    }

    private func populateViewFromURL(imageView: UIImageView, linkString: String, completion: (Void -> Void)? = nil) {
        if let imageURL = NSURL(string: linkString) {
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig)
            let imageDownload = session.downloadTaskWithURL(imageURL, completionHandler: {
                (imageLocation: NSURL?, response: NSURLResponse?, error: NSError?) in
                if let imageLocation = imageLocation,
                    let imageData = NSData(contentsOfURL: imageLocation),
                    let image = UIImage(data: imageData) {
                        dispatch_async(dispatch_get_main_queue(), {
                            imageView.image = image
                            completion?()
                        })
                } else {
                    NSLog("result/configure-cell/download/error Image Coulndn't be created")
                }
            })
            imageDownload.resume()
        } else {
            NSLog("result/configure-cell/error URL Creation Failed")
        }
    }
    
}

