//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by c.toan on 27.09.2022.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10
        let gestrueRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(close))
        gestrueRecognizer.cancelsTouchesInView = false
        gestrueRecognizer.delegate = self
        view.addGestureRecognizer(gestrueRecognizer)

    }

    //MARK: - Actions
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }

    
}
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        return (touch.view === self.view)
    }
}
