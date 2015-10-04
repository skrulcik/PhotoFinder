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
        static let requiredKeys = [ThumbnailURL, ImageURL, HumanReadableURL]
    }
    private var properties: [Key : AnyObject]


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

    func populateImageView(imageView: UIImageView) {
        // TODO: Load image asynchronously
    }
    
}

extension ImageResult: CollectionCellGenerator {
    var cellIdentifier: String {
            return ImageResultCell.identifier
    }

    func configureCell(rawCell: UICollectionViewCell) {
        if let resultCell = rawCell as? ImageResultCell {
            if let imageURL = NSURL(string: properties[.ImageURL] as! String) {
                NSLog("ImageURL: \(imageURL)")
                let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
                let session = NSURLSession(configuration: sessionConfig)
                let imageDownload = session.downloadTaskWithURL(imageURL, completionHandler: {
                    (imageLocation: NSURL?, response: NSURLResponse?, error: NSError?) in
                    if let imageLocation = imageLocation,
                        let imageData = NSData(contentsOfURL: imageLocation),
                        let image = UIImage(data: imageData) {
                            dispatch_async(dispatch_get_main_queue(), {
                                resultCell.preview.image = image
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
}
