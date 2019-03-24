//
//  URLTableViewCell.swift
//  AccessibilityURLs
//
//  Created by Armen Alikhanyan on 3/22/19.
//  Copyright © 2019 Armen Alikhanyan. All rights reserved.
//

import UIKit

class URLTableViewCell: UITableViewCell {

    @IBOutlet weak var URLLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
