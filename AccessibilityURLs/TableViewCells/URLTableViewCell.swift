//
//  URLTableViewCell.swift
//  AccessibilityURLs
//
//  Created by Armen Alikhanyan on 3/22/19.
//  Copyright © 2019 Armen Alikhanyan. All rights reserved.
//

import UIKit

class URLTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    // MARK: - Properties
    static let reuseIdentifier = "URLTableViewCellIdentifier"
    
    func configure(_ model: URLModel) {
        urlLabel.text = model.urlString
        switch model.urlType {
        case .success:
            statusImageView.tintColor = .green
        case .failure:
            statusImageView.tintColor = .red
        default:
            return
        }
        statusImageView.image = model.urlType.icon?.withRenderingMode(.alwaysTemplate)
    }
}
