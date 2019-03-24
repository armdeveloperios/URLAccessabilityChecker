//
//  UIALerts.swift
//  AccessibilityURLs
//
//  Created by Armen Alikhanyan on 3/23/19.
//  Copyright © 2019 Armen Alikhanyan. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAler(title: String, message: String, okAction: (() -> ())? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            okAction?()
        }
        
        ac.addAction(okAction)
        
        self.present(ac, animated: true, completion: nil)
    }
}
