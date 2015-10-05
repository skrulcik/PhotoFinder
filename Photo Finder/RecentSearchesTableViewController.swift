//
//  RecentSearchesTableViewController.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/5/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class RecentSearchesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    static let cellIdentifier = "RecentSearchCell"
    static let performSearchSegueID = "PerformSearch"
    static let managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate!
        return (appDelegate as! AppDelegate).managedObjectContext
        }()
    static let defaultBatchSize = 30
    var selectedSearch: RecentSearch?
    let fetchedResultsController: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: RecentSearch.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: RecentSearch.dateKey, ascending: false)]
        request.fetchBatchSize = RecentSearchesTableViewController.defaultBatchSize
        let fetcher = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RecentSearchesTableViewController.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetcher
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Recent Searches", comment: "Title of Recent Searches Page")
        fetchedResultsController.delegate = self
        self.clearsSelectionOnViewWillAppear = false
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        selectedSearch = nil
        do {
            try fetchedResultsController.performFetch()
        } catch {
            NSLog("recents/fetch/error \(error)")
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections
            where section < sections.count {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(RecentSearchesTableViewController.cellIdentifier, forIndexPath: indexPath)
        if let recentSearch = fetchedResultsController.objectAtIndexPath(indexPath) as? RecentSearch {
            cell.textLabel?.text = recentSearch.displayString
            cell.detailTextLabel?.text = recentSearch.formattedDate
        }
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */



    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == RecentSearchesTableViewController.performSearchSegueID {
            if let cell = sender as? UITableViewCell,
                let selectedIndex = tableView.indexPathForCell(cell),
                let recentSearch = fetchedResultsController.objectAtIndexPath(selectedIndex) as? RecentSearch {
                    selectedSearch = recentSearch
            }
        }
    }

    // MARK: Fetched Results Controller Delegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("Begin updates")
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if let indexPath = indexPath {
            if type == .Delete {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            } else if type == .Insert {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }



}
