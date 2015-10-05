//
//  LoadMoreReusableView.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/4/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//


import UIKit

protocol LoadMoreReusableViewDelegate {
    func loadMore()
}

class LoadMoreReusableView: UICollectionReusableView {
    static let identifier = "LoadMore"
    @IBOutlet var loadButton:UIButton!
    var delegate: LoadMoreReusableViewDelegate?

    @IBAction func loadMorePressed() {
        delegate?.loadMore()
    }
}
