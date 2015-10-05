//
//  ImageDetailViewController.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/4/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var infoLabel: UITextView!
    @IBOutlet weak var pinwheel: UIActivityIndicatorView!
    var imageResult: ImageResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let imageResult = imageResult {
            setupWithImageResult(imageResult)
        }
    }

    private func setupWithImageResult(imageResult: ImageResult) {
        mainLabel.text = imageResult.imageTitle
        infoLabel.text = imageResult.imageDescription
        pinwheel.startAnimating()
        imageResult.populateViewWithImage(image) { self.pinwheel.stopAnimating() }
    }
}
