//
//  SearchResultsViewController.swift
//  Photo Finder
//
//  Created by Scott Krulcik on 10/4/15.
//  Copyright © 2015 Scott Krulcik. All rights reserved.
//

import UIKit
import CoreData


class SearchResultsViewController: UIViewController, UISearchBarDelegate, UIScrollViewDelegate {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var scrollView: UIScrollView!

    private static let detailSegueID = "ImageDetail"
    private static let viewRecentsSegueID = "RecentSearches"
    private var imageSearch = ImageSearchController()
    private var resultsToDisplay = [ImageResult]()
    private var resultViews = [ImageResultView]()
    private var minimumResultsToShow = 24
    private var lastRequestedIndex = 0
    private var currentQuery: String?
    var currentSelection: ImageResult?

    private var imageSpacing: CGFloat = 2
    private var maxImageWidth: CGFloat = 120
    private var bottomReloadBuffer: CGFloat = 300
    private var lastLoadRequest: NSTimeInterval = 0.0
    private var minimumPauseBetweenLoadRequests: NSTimeInterval = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Photo Finder", comment: "Title of main search page")

        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.showsBookmarkButton = true
        searchBar.barTintColor = Color.primaryColor
        searchBar.tintColor = Color.secondaryColor
        searchBar.placeholder = NSLocalizedString("Image Search", comment: "Placeholder for main search bar")
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = Color.primaryColor

        scrollView.delegate = self
        layoutInScrollView(view.frame.width)
    }

    private func dismissKeyboard() {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }

    private func layoutInScrollView(width: CGFloat, startIndex: Int = 0) {
        if resultsToDisplay.count > 0 {
            let imageSize = CGSize(width: maxImageWidth, height: maxImageWidth)
            let imPerRow = imagesPerRowForWidth(width)
            let spacing = spacingForWidth(width, withImageCount: CGFloat(imPerRow))
            let totalHeight = heightOfAllImages(resultsToDisplay.count, imagesPerRow: imPerRow, spacing: spacing, imageHeight: imageSize.height)
            scrollView.contentSize = CGSizeMake(width, totalHeight)

            var index = startIndex
            var minX: CGFloat = 0
            var minY: CGFloat = spacing
            var resultView: ImageResultView
            while index < resultsToDisplay.count {
                let origin = CGPoint(x: minX, y: minY)
                resultView = dequeueResultViewForIndex(index)
                resultView.frame = CGRect(origin: origin, size: imageSize)
                let object = resultsToDisplay[index]
                if resultView.imageResult == nil || object != resultView.imageResult! {
                    resultView.imageResult = object
                }

                index += 1
                if index % imPerRow == 0 {
                    minX = 0
                    minY += spacing
                    minY += imageSize.height
                } else {
                    minX += spacing
                    minX += imageSize.width
                }
            }
//            removeResultViewsBeyondIndex(resultsToDisplay.count)
        }
    }
    private func imagesPerRowForWidth(width: CGFloat) -> Int {
        return Int(width / maxImageWidth)
    }
    private func spacingForWidth(width: CGFloat, withImageCount count: CGFloat) -> CGFloat {
        return (width - (count * maxImageWidth)) / count
    }
    private func heightOfAllImages(totalCount: Int, imagesPerRow: Int, spacing: CGFloat, imageHeight: CGFloat) -> CGFloat {
        let numRows = ceil(CGFloat(totalCount) / CGFloat(imagesPerRow))
        return numRows * (spacing + imageHeight)
    }
    private func dequeueResultViewForIndex(index: Int) -> ImageResultView {
        if index < resultViews.count {
            return resultViews[index]
        }
        let newResultView = NSBundle.mainBundle().loadNibNamed("ImageResultView", owner: self, options: nil).first as! ImageResultView
        resultViews.append(newResultView)
        scrollView.addSubview(newResultView)
        return newResultView
    }
    private func removeResultViewsBeyondIndex(index: Int) {
        if index < resultViews.count {
            resultViews = Array(resultViews.dropLast(resultViews.count - index))
        }
    }

    /* Overridden to ensure UISearchBar resizes properly on rotation */
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({
            (context) in
                self.layoutInScrollView(size.width)
            }, completion: nil)
    }

    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let now = NSDate().timeIntervalSince1970
        if now > lastLoadRequest + minimumPauseBetweenLoadRequests {
            lastLoadRequest = now
            let totalHeight = scrollView.contentSize.height
            let bottomY = scrollView.frame.height + scrollView.contentOffset.y
            if bottomY + bottomReloadBuffer > totalHeight {
                loadMore()
            }
        }

    }

    // MARK: UISearchBarDelegate
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        dismissKeyboard()
        performSegueWithIdentifier(SearchResultsViewController.viewRecentsSegueID, sender: self)
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissKeyboard()
        searchBar.text = nil
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        dismissKeyboard()
        if let rawText = searchBar.text {
            let queryString = rawText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            imageSearch.addQueryToHistory(rawText, clean: queryString)
            loadInitialSearch(queryString)
        }
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func loadInitialSearch(queryString: String, resultCount: Int = 0) {
        if queryString.characters.count > 0 {
            currentQuery = queryString
            resultsToDisplay = []
            lastRequestedIndex = 0
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                for i in 0..<(self.minimumResultsToShow / self.imageSearch.chunkSize) {
                    self.loadFromOffset(i * self.imageSearch.chunkSize)
                }
            })
        }
    }

    // MARK: LoadMoreReusableViewDelegate
    func loadFromOffset(offset: Int) {
        if offset >= lastRequestedIndex {
            lastRequestedIndex = offset + imageSearch.chunkSize
            if let queryString = currentQuery {
                imageSearch.queryForImages(query: queryString, withOffset: offset,{
                    (results: [ImageResult]?) in
                    if let results = results
                        where queryString == self.currentQuery {
                            // 'where' clause ensures we don't add results if they took too long
                            // and the user has entered a new string before they've been displayed
                            dispatch_async(dispatch_get_main_queue(), {
                                self.resultsToDisplay += results
                                self.layoutInScrollView(self.view.frame.width)
                            })
                    }
                })
            }
        }
    }

    func loadMore() {
        loadFromOffset(lastRequestedIndex)
    }

    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SearchResultsViewController.detailSegueID,
            let detailVC = segue.destinationViewController as? ImageDetailViewController,
            let selectedImageResult = currentSelection {
                detailVC.imageResult = selectedImageResult
        }
    }

    @IBAction func closeRecentSearches(segue: UIStoryboardSegue) { }
    @IBAction func performRecentSearch(segue: UIStoryboardSegue) {
        if segue.identifier == RecentSearchesTableViewController.performSearchSegueID,
            let recentSearchesTVC = segue.sourceViewController as? RecentSearchesTableViewController,
            let lastSearch = recentSearchesTVC.selectedSearch,
            let queryString = lastSearch.queryString {
                searchBar.text = queryString
                loadInitialSearch(queryString)
        }
    }

}
