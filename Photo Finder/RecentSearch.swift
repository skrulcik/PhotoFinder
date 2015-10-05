//
//  RecentSearch.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/5/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

import Foundation
import CoreData


class RecentSearch: NSManagedObject {

    static let entityName = "RecentSearch"
    static let dateKey = "lastSearchDate"
    static let queryStringKey = "queryString"
    static let displayStringKey = "displayString"

    var formattedDate: String {
        let date = NSDate(timeIntervalSince1970: lastSearchDate)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.stringFromDate(date)
    }

    func updateLastSearch() {
        lastSearchDate = NSDate().timeIntervalSince1970
        dispatch_async(dispatch_get_main_queue(), {
            do {
                try self.managedObjectContext?.save()
            } catch {
                NSLog("recent-search/update-date/error \(error)")
            }
        })
    }
}
