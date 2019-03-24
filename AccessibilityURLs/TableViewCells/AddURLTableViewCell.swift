//
//  AddURLTableViewCell.swift
//  AccessibilityURLs
//
//  Created by Armen Alikhanyan on 3/22/19.
//  Copyright © 2019 Armen Alikhanyan. All rights reserved.
//

import UIKit

protocol AddURLTableViewCellDelegate: class {
    func addURLTableViewCellDidEndEditing(_ cell: AddURLTableViewCell) -> Bool
}

class AddURLTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var urlTextField: UITextField!
    
    // MARK: - Properties
    static let reuseIdentifier = "AddURLIdentifier"
    weak var delegate: AddURLTableViewCellDelegate?
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.urlTextField.delegate = self;
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        urlTextField.text = nil
    }
}

extension AddURLTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let delegate = delegate {
            return delegate.addURLTableViewCellDidEndEditing(self)
        }
        return true
    }
}
