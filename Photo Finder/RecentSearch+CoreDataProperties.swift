//
//  RecentSearch+CoreDataProperties.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/5/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension RecentSearch {

    @NSManaged var queryString: String?
    @NSManaged var displayString: String?           // Indexed
    @NSManaged var lastSearchDate: NSTimeInterval   // Indexed

}
