//
//  CollectionCellGenerator.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/3/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

import Foundation
import UIKit


/**

Objects conforming to CollectionCellGenerator are model objects that provide
a UICollectionViewCell representation.

*/
protocol CollectionCellGenerator {
    /// CellIdentifier used to dequeue reusable cells, should be unique
    var cellIdentifier: String { get }

    /**
    Takes in a `UICollectionViewCell` (assumed to have been dequeued with
    the designated cellIdentifier), and configures it to represent the current
    object.
    */
    func configureCell(rawCell: UICollectionViewCell)
}


