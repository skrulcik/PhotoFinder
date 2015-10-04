//
//  ImageResult.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/4/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

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
            resultCell.label.text = properties[.HumanReadableURL] as? String
        }
    }
}
