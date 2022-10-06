//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by c.toan on 01.10.2022.
//

import UIKit

class LandscapeViewController: UIViewController {
    var search: Search!
    private var firstTime = true
    private var downloads = [URLSessionDownloadTask] ()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Remove constraints from main view
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        // Remove constraints for page control
        pageControll.removeConstraints(pageControll.constraints)
        pageControll.translatesAutoresizingMaskIntoConstraints = true
        // Remove constraints for scroll view
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        //scrollView.contentSize = CGSize(width: 1000, height: 1000)
        pageControll.numberOfPages = 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame = safeFrame
        pageControll.frame = CGRect(
            x: safeFrame.origin.x,
            y: safeFrame.size.height - pageControll.frame.size.height,
            width: safeFrame.size.width,
            height: pageControll.frame.size.height)
        
        if firstTime {
            firstTime = false
            
            switch search.state {
            case .notSearchedYet, .loading, .noResults:
                break
            case .results(let list):
                tileButtons(list)
            }
            
        }
    }
    
    private func tileButtons(_ searchResults: [SearchResults]) {
        let itemWidth: CGFloat = 94
        let itemHeight: CGFloat = 88
        var columsPerPage = 0
        var rowsPerPage = 0
        var marginX: CGFloat = 0
        var marginY: CGFloat = 0
        let viewWidth: CGFloat = scrollView.bounds.size.width
        let viewHeight: CGFloat = scrollView.bounds.size.height
        
        let buttonWidth: CGFloat = 82
        let buttonHeigth: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeigth) / 2
        
        columsPerPage = Int(viewWidth / itemWidth)
        rowsPerPage = Int(viewHeight / itemHeight)
        
        marginX = (viewWidth - (CGFloat(columsPerPage) * itemWidth)) * 0.5
        marginY = (viewHeight - (CGFloat(rowsPerPage) * itemHeight)) * 0.5
        
        var row = 0
        var column = 0
        var x = marginX
        
        for(index , result) in search.searchResults.enumerated() {
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            button.frame = CGRect(
                x: x + paddingHorz,
                y: marginY + CGFloat(row) * itemHeight + paddingVert,
                width: buttonWidth,
                height: buttonHeigth)
            scrollView.addSubview(button)
            downloadImage(for: result, andPlaceOn: button)
            row += 1
            if row == rowsPerPage {
                row = 0; x += itemWidth; column += 1
                if column == columsPerPage {
                    column = 0; x += marginX * 2
                }
            }
        }
        
        let buttonPerPage = columsPerPage * rowsPerPage
        let numPages = 1 + (search.searchResults.count - 1) / buttonPerPage
        scrollView.contentSize = CGSize(
            width: CGFloat(numPages) * viewWidth,
            height: scrollView.bounds.size.height)
        print("Number of pages: \(numPages)")
        
        pageControll.numberOfPages = numPages
        pageControll.currentPage = 0
        
    }
    private func downloadImage(
        for searchResult: SearchResults,
        andPlaceOn button: UIButton
    ) {
        if let url = URL(string: searchResult.imageSmall) {
            let task = URLSession.shared.downloadTask(with: url) {
                [weak button] url, _, error in
                if error == nil, let url = url,
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let button = button {
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            task.resume()
            downloads.append(task)
        }
        }
    deinit {
        print("deinit \(self)")
        for task in downloads {
            task.cancel()
        }
    }
    @IBAction func pageChanged (_ sender: UIPageControl) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.scrollView.contentOffset = CGPoint(
                    x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
                    y: 0)
            },
            completion: nil)
    }
}
extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControll.currentPage = page
    }
}
