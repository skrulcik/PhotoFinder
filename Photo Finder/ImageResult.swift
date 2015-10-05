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
    private enum Key: String {
        case ThumbnailURL = "tbUrl"
        case ImageURL = "url"
        case HumanReadableURL = "visibleUrl"
        case Title = "titleNoFormatting"
        case Description = "contentNoFormatting"
        static let requiredKeys = [ThumbnailURL, ImageURL, HumanReadableURL, Title, Description]
    }
    private var properties: [Key : AnyObject]
    private var thumbnail: UIImage?
    private var fullImage: UIImage?
    var imageTitle: String {
        return properties[.Title] as! String
    }
    var imageDescription: String {
        let url = properties[.HumanReadableURL] as! String
        let info = properties[.Description] as! String
        return "\(url)\n\(info)"
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
        properties = [:]
        super.init()
        for key in Key.requiredKeys {
            if let obj = json[key.rawValue] {
                properties[key] = obj
            } else {
                return nil
            }
        }
    }

    /**
    Downloads full image (if necessary) and populates the given UIImageView
    Completion handler is only called on success
    */
    func populateViewWithImage(imageView: UIImageView, completion: (Void -> Void)? = nil) {
        if let fullImage = fullImage {
            imageView.image = fullImage
            completion?()
        } else {
            populateViewFromURL(imageView, .ImageURL, completion: completion)
        }
    }
    /**
    Downloads thumbnail (if necessary) and populates the given UIImageView
    Completion handler is only called on success
    */
    func populateViewWithImageThumbnail(imageView: UIImageView, completion: (Void -> Void)? = nil) {
        if let thumbnail = thumbnail {
            imageView.image = thumbnail
            completion?()
        } else {
            populateViewFromURL(imageView, .ThumbnailURL, completion: completion)
        }
    }
    private func populateViewFromURL(imageView: UIImageView, _ urlKey: Key, completion: (Void -> Void)? = nil) {
        if let imageURL = NSURL(string: properties[urlKey] as! String) {
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig)
            let imageDownload = session.downloadTaskWithURL(imageURL, completionHandler: {
                (imageLocation: NSURL?, response: NSURLResponse?, error: NSError?) in
                if let imageLocation = imageLocation,
                    let imageData = NSData(contentsOfURL: imageLocation),
                    let image = UIImage(data: imageData) {
                        if urlKey == .ThumbnailURL {
                            self.thumbnail = image
                        } else if urlKey == .ImageURL {
                            self.fullImage = image
                        }
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

