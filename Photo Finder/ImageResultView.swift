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
                imageView.image = nil
                pinwheel.startAnimating()
                imageResult.populateViewWithImageThumbnail(imageView) {
                    self.pinwheel.stopAnimating()
                }
            }
        }
    }
}
