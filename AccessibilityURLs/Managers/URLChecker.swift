//
//  URLChecker.swift
//  AccessibilityURLs
//
//  Created by Armen Alikhanyan on 3/23/19.
//  Copyright © 2019 Armen Alikhanyan. All rights reserved.
//

import Foundation


struct URLChecker {
    func check(urlString: String, completion: @escaping (_ type: URLType, _ time: Double) -> ()) {
        check(urlString: urlString, atIndex: 0) { (urlType, time, itemIndex) in
            completion(urlType, time)
        }
    }
    
    // MARK: - Public API
    
    func check(urlString: String, atIndex index: Int, completion: @escaping (_ type: URLType, _ time: Double, _ itemIndex: Int) ->()) {
        let correctUrlString = correct(urlString)
        if let url = URL(string: correctUrlString) {
            let request = URLRequest(url: url)
            let session = URLSession.shared
            let startTime = Date()
            let task =  session.dataTask(with: request) { (data, resp, error) in
                guard error == nil && data != nil else {
                    print("connection error or data is nill\(String(describing: error?.localizedDescription))")
                    completion(.failure, 0, index)
                    return
                }
                
                guard resp != nil else {
                    print("respons is nill")
                    completion(.failure, 0, index)
                    return
                }
                let duration: TimeInterval = Date().timeIntervalSince(startTime)
                debugPrint(duration)
                completion(.success, duration, index)
            }
            task.resume()
        } else {
            completion(.failure, 0, index)
        }
    }
    
    // MARK: - Private API
    
    private func correct(_ urlString: String) -> String {
        let lowercasedURL = urlString.lowercased()
        if !lowercasedURL.starts(with: "http://") && !lowercasedURL.starts(with: "https://") {
            if !lowercasedURL.starts(with: "www.") {
                return "https://www.\(lowercasedURL)"
            }
                return "https://\(lowercasedURL)"
        }
        
        if !lowercasedURL.contains("://www") {
            if let range = lowercasedURL.range(of:"://") {
                return lowercasedURL.replacingCharacters(in:range, with: "://www.")
            }
        }

        return lowercasedURL
            
        }
}
