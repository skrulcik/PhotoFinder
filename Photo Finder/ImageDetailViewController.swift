//
//  ImageDetailViewController.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/4/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

import UIKit


/**
 * This provides a high resolution version of the image, as well as a more
 * detailed description and link to the original site.
 */
class ImageDetailViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var infoLabel: UITextView!
    @IBOutlet weak var pinwheel: UIActivityIndicatorView!
    private var index: Int = 0
    private var imageResults = [ImageResult]()


    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setupWithImageResult(imageResults: [ImageResult], index: Int = 0) {
        self.imageResults = imageResults
        self.index = index
    }

    private func setup() {
        if index < imageResults.count {
            let imageResult = imageResults[index]
            mainLabel.text = imageResult.imageTitle
            infoLabel.text = imageResult.imageDescription
            pinwheel.startAnimating()
            imageResult.populateViewWithImage(image) { self.pinwheel.stopAnimating() }
        }
    }

    // MARK: Swipe gestures
    // Note, swipe down to dismiss is also implemented, but as a segue
    @IBAction func swipeRight(sender: AnyObject) {
        index = (index - 1) % imageResults.count
        setup()
    }
    @IBAction func swipeLeft(sender: AnyObject) {
        index = (index + 1) % imageResults.count
        setup()
    }
}
