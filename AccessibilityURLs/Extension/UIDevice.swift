//
//  UIDevice.swift
//  AccessibilityURLs
//
//  Created by Armen Alikhanyan on 3/24/19.
//  Copyright © 2019 Armen Alikhanyan. All rights reserved.
//

import UIKit

extension UIDevice {
    class func isIphone() -> Bool {
        let deviceIdom = UIScreen.main.traitCollection.userInterfaceIdiom
        
        switch deviceIdom {
        case .phone:
            return true
        default:
            return false
        }
    }
}
