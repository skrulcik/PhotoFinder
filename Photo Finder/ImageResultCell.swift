//
//  ImageResultCell.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/3/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

import UIKit

class ImageResultCell: UICollectionViewCell {
    static let identifier = "ImageResultCell"
    @IBOutlet var preview: UIImageView!
    @IBOutlet var pinwheel: UIActivityIndicatorView!
    var loading: Bool = false {
        didSet {
            if loading {
                preview.image = nil
                pinwheel.startAnimating()
            } else {
                pinwheel.stopAnimating()
            }
        }
    }
}
