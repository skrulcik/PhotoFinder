//
//  SearchResultsViewController.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/3/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

import UIKit



class SearchResultsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    @IBOutlet var searchBarWrapper: UIView!
    @IBOutlet var collectionView: UICollectionView!
    private let numSectionsEmpty = 0
    private let numSectionsResults = 1
    private let resultsSection = 0

    private var searchController = UISearchController(searchResultsController: nil)
    private var resultsToDisplay = ["result 1", "result 2", "result 3"]//[String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.barTintColor = Color.primaryColor
        searchController.searchBar.tintColor = Color.secondaryColor
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = Color.primaryColor

        searchBarWrapper.addSubview(searchController.searchBar)
        searchBarWrapper.sizeToFit()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }

    /* Overridden to ensure UISearchBar resizes properly on rotation */
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        print("Will Transition")
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({
            (context: UIViewControllerTransitionCoordinatorContext) in
                self.searchController.searchBar.frame = CGRect(x: self.searchController.searchBar.frame.minX,
                                                                y: self.searchController.searchBar.frame.minY,
                                                                width: size.width,
                                                                height: self.searchController.searchBar.frame.height)
            }, completion: nil)
    }

    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print(searchController.searchBar.text)
    }

    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if resultsToDisplay.count == 0 {
            return numSectionsEmpty
        }
        return numSectionsResults
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == resultsSection {
            return resultsToDisplay.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageResultCell.identifier, forIndexPath: indexPath)
        if let resultCell = cell as? ImageResultCell
        where indexPath.row < resultsToDisplay.count {
            resultCell.label.text = resultsToDisplay[indexPath.row]
        }
        return cell
    }

    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    // MARK: UISearchBarDelegate
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        // TODO: History
        print("Examine History")
    }


}
