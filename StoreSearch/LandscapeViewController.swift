//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by c.toan on 01.10.2022.
//

import UIKit

class LandscapeViewController: UIViewController {
    var searchResults = [SearchResults] ()
    private var firstTime = true
    
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
            tileButtons(searchResults)
            
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
        
        for(index , result) in searchResults.enumerated() {
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor.white
            button.setTitle("\(index)", for: .normal)
            
            button.frame = CGRect(
                x: x + paddingHorz,
                y: marginY + CGFloat(row) * itemHeight + paddingVert,
                width: buttonWidth,
                height: buttonHeigth)
            scrollView.addSubview(button)
            row += 1
            if row == rowsPerPage {
                row = 0; x += itemWidth; column += 1
                if column == columsPerPage {
                    column = 0; x += marginX * 2
                }
            }
        }
        
        let buttonPerPage = columsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonPerPage
        scrollView.contentSize = CGSize(
            width: CGFloat(numPages) * viewWidth,
            height: scrollView.bounds.size.height)
        print("Number of pages: \(numPages)")
        
    }
}
