//
//  LoadingCell.swift
//  AccessibilityURLs
//
//  Created by Armen Alikhanyan on 3/23/19.
//  Copyright © 2019 Armen Alikhanyan. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Properties
    static let reuseIdentifier = "LoadingCellIdentifier"
    
    // MARK: - LifeCycle
    deinit {
        stopLoading()
    }
    
    // MARK: - Public API
    func configure(_ model: URLModel) {
        urlLabel.text = model.urlString
        startLoading()
    }
    
    // MARK: - Private API
    private func startLoading() {
        loadingIndicatorView.startAnimating()
    }
    
    private func stopLoading() {
        loadingIndicatorView.stopAnimating()
    }
}
