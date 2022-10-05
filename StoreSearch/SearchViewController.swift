//
//  ViewController.swift
//  StoreSearch
//
//  Created by c.toan on 17.09.2022.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private let search = Search()
    var landscapeVC: LandscapeViewController?
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        tableView.contentInset = UIEdgeInsets(top: 91, left: 0, bottom: 0, right: 0)
        var cellNib = UINib(
            nibName: TableView.CellIdentifiers.searchResultCell,
            bundle: nil)
        tableView.register(
            cellNib,
            forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(
            nibName: TableView.CellIdentifiers.nothingFoundCell,
            bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(
            nibName: TableView.CellIdentifiers.loadingCell,
            bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
    }
    
    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    
    

    func showNetworkError() {
        let alert = UIAlertController(
            title: "Whooops...",
            message: "There was an error accessing the iTunes Store." +
            " Please try again.",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let searchResult = search.searchResults[indexPath.row]
            detailViewController.searchResult = searchResult
        }
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else { return }
        
        landscapeVC = storyboard?.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeVC {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
            addChild(controller)
            coordinator.animate(
                alongsideTransition: { _ in
                    controller.view.alpha = 1
                    self.searchBar.resignFirstResponder()
                    if self.presentedViewController != nil {
                        self.dismiss(animated: true, completion: nil)
                    }
                }, completion: { _ in
                    controller.didMove(toParent: self)
                })
        }
    }
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            coordinator.animate(
                alongsideTransition: { _ in
                    controller.view.alpha = 0
                }, completion: { _ in
                    controller.view.removeFromSuperview()
                    controller.removeFromParent()
                    self.landscapeVC = nil
                })
        }
    }
}
//MAKR: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    func performSearch() {
      if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
        search.performSearch(for: searchBar.text!, category: category) { success in
          if !success {
            self.showNetworkError()
          }
          self.tableView.reloadData()
//          self.landscapeVC?.searchResultsReceived()
        }

        tableView.reloadData()
        searchBar.resignFirstResponder()
      }
    }
}
    // MARK: - Table View Delegate
    extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(
            _ tableView: UITableView,
            numberOfRowsInSection section: Int
        ) -> Int {
            switch search.state {
            case .notSearchedYet:
                return 0
            case .loading:
                return 1
            case .noResults:
                return 1
            case .results(let list):
                return list.count
            }
            
        }
        func tableView(
            _ tableView: UITableView,
            cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
            let cellIdentifier = TableView.CellIdentifiers.searchResultCell
            
            var cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath) as! SearchResultCell
            if search.isLoading {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: TableView.CellIdentifiers.loadingCell,
                    for: indexPath)
                
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                return cell
                
            } else
            if search.searchResults.count == 0 {
                return tableView.dequeueReusableCell(
                    withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
                    for: indexPath)
            } else {
                let searchResult = search.searchResults[indexPath.row]
                cell.configure(for: searchResult)
            }
            
            return cell
        }
        
        func position(for bar: UIBarPositioning) -> UIBarPosition {
            return .topAttached
        }
        
        func tableView(
            _ tableView: UITableView,
            didSelectRowAt indexPath: IndexPath
        ) {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        }
        
        func tableView(
            _ tableView: UITableView,
            willSelectRowAt indexPath: IndexPath
        ) -> IndexPath? {
            if search.searchResults.count == 0 || search.isLoading {
                return nil
            } else {
                return indexPath
            }
        }
        
    }

