//
//  SearchResultsViewController.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/4/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

import UIKit



class SearchResultsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, LoadMoreReusableViewDelegate {
    @IBOutlet var searchBarWrapper: UIView!
    @IBOutlet var collectionView: UICollectionView!
    private let numSectionsEmpty = 0
    private let numSectionsResults = 1
    private let resultsSection = 0

    private static let detailSegueID = "ImageDetail"
    private var searchController = UISearchController(searchResultsController: nil)
    private var imageSearch = ImageSearchController()
    private var resultsToDisplay = [CollectionCellGenerator]()
    private var minimumResultsToShow = 24
    private var currentQuery: String?
    var currentSelection: ImageResult?

    // UICollectionView layout parameters
    private let cellSpacing: CGFloat = 2
    private let cellsPerRow: CGFloat = 4
    private let footerHeight: CGFloat = 50
    private let collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        return layout
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.barTintColor = Color.primaryColor
        searchController.searchBar.tintColor = Color.secondaryColor
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = Color.primaryColor

        searchBarWrapper.addSubview(searchController.searchBar)
        searchBarWrapper.sizeToFit()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()

        /* The following uses view.frame rather than collectionView.frame
        because collectionView's size is not always updated by the time
        viewDidLoad is called */
        updateFlowLayoutForWidth(view.frame.width)
    }

    private func updateFlowLayoutForWidth(width: CGFloat) {
        let cellWidth = (width - (cellSpacing * (cellsPerRow - 1))) / cellsPerRow
        collectionLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        collectionLayout.footerReferenceSize = CGSize(width: width, height: footerHeight)
        collectionView.setCollectionViewLayout(collectionLayout, animated: true)
    }

    /* Overridden to ensure UISearchBar resizes properly on rotation */
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({
            (context: UIViewControllerTransitionCoordinatorContext) in
                self.searchController.searchBar.frame = CGRect(x: self.searchController.searchBar.frame.minX,
                                                                y: self.searchController.searchBar.frame.minY,
                                                                width: size.width,
                                                                height: self.searchController.searchBar.frame.height)
            }, completion: nil)
        updateFlowLayoutForWidth(size.width)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchBarWrapper.hidden = true
        searchController.searchBar.hidden = true
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchBarWrapper.hidden = false
        searchController.searchBar.hidden = false
    }

    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // TODO: Fiter shown history as text is typed like Google Instant Search
    }

    // MARK: UISearchBarDelegate
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        // TODO: History
        print("Examine History")
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        if let rawText = searchBar.text {
            let queryString = rawText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            loadInitialSearch(queryString)
        }
    }
    func loadInitialSearch(queryString: String, resultCount: Int = 0) {
        if queryString.characters.count > 0 {
            currentQuery = queryString
            resultsToDisplay = []
            for i in 0..<(self.minimumResultsToShow / imageSearch.chunkSize) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    self.loadFromOffset(i * self.imageSearch.chunkSize)
                })
            }
        }
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
        let objectForCell = resultsToDisplay[indexPath.item]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(objectForCell.cellIdentifier, forIndexPath: indexPath)
        objectForCell.configureCell(cell)
        return cell
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if indexPath.section == resultsSection {
            let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: LoadMoreReusableView.identifier, forIndexPath: indexPath)
            if let loadMore = reusableView as? LoadMoreReusableView {
                loadMore.delegate = self
            }
            return reusableView
        }
        return UICollectionReusableView()
    }

    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == resultsSection && indexPath.item < resultsToDisplay.count {
            currentSelection = resultsToDisplay[indexPath.item] as? ImageResult
            performSegueWithIdentifier(SearchResultsViewController.detailSegueID, sender: self)
        }
    }

    // MARK: LoadMoreReusableViewDelegate
    func loadFromOffset(offset: Int) {
        if let queryString = currentQuery {
            imageSearch.queryForImages(query: queryString, withOffset: offset,{
                (results: [ImageResult]?) in
                if let results = results
                    where queryString == self.currentQuery {
                        // 'where' clause ensures we don't add results if they took too long
                        // and the user has entered a new string before they've been displayed
                        let trueResults = results.map({ $0 as CollectionCellGenerator}) // Keep the compiler happy
                        self.resultsToDisplay += trueResults
                        dispatch_async(dispatch_get_main_queue(), {
                            self.collectionView.reloadData()
                        })
                }
            })
        }
    }
    func loadMore() {
        loadFromOffset(resultsToDisplay.count)
    }

    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SearchResultsViewController.detailSegueID,
            let detailVC = segue.destinationViewController as? ImageDetailViewController,
            let selectedImageResult = currentSelection {
                detailVC.imageResult = selectedImageResult
        }
    }
}
