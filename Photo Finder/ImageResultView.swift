//
//  ImageResultView.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/5/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

import UIKit

class ImageResultView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pinwheel: UIActivityIndicatorView!


    var imageResult: ImageResult? {
        didSet {
            if let imageResult = imageResult {
                let currentResult = imageResult
                self.loading = true
                imageResult.populateViewWithImageThumbnail(imageView) {
                    self.loading = false
                    // Load higher quality if still the same source object
                    if self.imageResult != nil && currentResult == self.imageResult! {
                        self.imageResult!.populateViewWithImage(self.imageView)
                    }
                }
            }
        }
    }
    var loading: Bool = true {
        didSet {
            if loading {
                imageView.image = nil
                pinwheel.startAnimating()
            } else {
                pinwheel.stopAnimating()
            }
        }
    }
}
