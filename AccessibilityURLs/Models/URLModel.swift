//
//  URLModel.swift
//  AccessibilityURLs
//
//  Created by Armen Alikhanyan on 3/22/19.
//  Copyright © 2019 Armen Alikhanyan. All rights reserved.
//

import UIKit

enum URLType: Int {
    case loading
    case success
    case failure
    
    var icon: UIImage? {
        switch self {
        case .loading:
            return nil
        case .success:
            return #imageLiteral(resourceName: "ic_success")
        case .failure:
            return #imageLiteral(resourceName: "ic_failure")
        }
    }
}

class URLModel {
    var urlString : String!
    var duringTime : Double!
    var urlType: URLType
    init(_ urlString: String!, _ type: URLType!, _ duringTime: Double) {
        self.urlString = urlString
        self.urlType = type
        self.duringTime = duringTime
    }
}
