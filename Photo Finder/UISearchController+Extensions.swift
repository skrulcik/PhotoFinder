//
//  UISearchController+Extensions.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/3/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

import UIKit

extension UISearchController {
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIApplication.sharedApplication().statusBarStyle
    }
}
