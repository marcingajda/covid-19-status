//
//  ApiFetcher.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 04/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa

typealias FetchComplete = ((CoronaStats?, String?) -> Void)

enum ApiEndpoint: String {
    case stats = "https://corona-stats.online?format=json&source=2"
}

class ApiClient: NSObject {
    static func fetchData(onComplete: @escaping FetchComplete) {
        guard let url = NSURL(string: ApiEndpoint.stats.rawValue)?.absoluteURL else {
            ErrorHandler.standard.critical(withMessage: "API address is not an URL")
            return
        }

        let request = NSMutableURLRequest(
            url: url,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )

        request.httpMethod = "GET"
        let session = URLSession.shared

        let dataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, _, error) -> Void in
                self.parseResponse(data: data, error: error, onComplete: onComplete)
            }
        )

        dataTask.resume()
    }

    static func parseResponse(data: Data?, error: Error?, onComplete: FetchComplete) {
        if let error = error {
            onComplete(nil, error.localizedDescription)
            return
        }

        if let data = data {
            do {
                let response = try JSONDecoder().decode(CoronaStats.self, from: data)
                onComplete(response, nil)
            } catch let error {
                onComplete(nil, error.localizedDescription)
                print(error)
            }
        }
    }
}
