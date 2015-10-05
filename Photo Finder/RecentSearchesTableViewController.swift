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

class RecentSearchesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    static let cellIdentifier = "RecentSearchCell"
    static let performSearchSegueID = "PerformSearch"
    static let managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate!
        return (appDelegate as! AppDelegate).managedObjectContext
        }()
    static let defaultBatchSize = 30
    var selectedSearch: RecentSearch?
    var searchController = UISearchController(searchResultsController: nil)
    let fetchedResultsController: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: RecentSearch.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: RecentSearch.dateKey, ascending: false)]
        request.fetchBatchSize = RecentSearchesTableViewController.defaultBatchSize
        let fetcher = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RecentSearchesTableViewController.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetcher
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Recent Searches", comment: "Title of Recent Searches Page")

        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = Color.primaryColor
        searchController.searchBar.tintColor = Color.secondaryColor
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.placeholder = NSLocalizedString("Search Recents", comment: "Search bar placeholder for recent searches screen")
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = Color.primaryColor
        tableView.tableHeaderView = searchController.searchBar

        fetchedResultsController.delegate = self
        clearsSelectionOnViewWillAppear = false

        do {
            try fetchedResultsController.performFetch()
        } catch {
            NSLog("recents/fetch/initial/error \(error)")
        }
    }

    // MARK: - TableViewDataSource
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

    // MARK: FetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
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

    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let partialQuery = searchController.searchBar.text
            where partialQuery.characters.count > 0 {
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "\(RecentSearch.displayStringKey) LIKE[c] %@", partialQuery + "*")
            do {
                NSFetchedResultsController.deleteCacheWithName(fetchedResultsController.cacheName)
                try fetchedResultsController.performFetch()
                tableView.reloadData()
            } catch {
                NSLog("recents/fetch/instant-filter/error \(error)")
            }
        }
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == RecentSearchesTableViewController.performSearchSegueID {
            if let cell = sender as? UITableViewCell,
                let selectedIndex = tableView.indexPathForCell(cell),
                let recentSearch = fetchedResultsController.objectAtIndexPath(selectedIndex) as? RecentSearch {
                    recentSearch.updateLastSearch()
                    selectedSearch = recentSearch
            }
        }
    }

}
