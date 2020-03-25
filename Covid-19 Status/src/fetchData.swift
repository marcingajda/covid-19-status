//
//  fetchData.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 24/03/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Foundation

var API = "https://corona-stats.online?format=json&source=2";

func fetchData(completion: @escaping ((CoronaStats?, String?) -> Void)) {
    let request = NSMutableURLRequest(
        url: NSURL(string: API)! as URL,
        cachePolicy: .useProtocolCachePolicy,
        timeoutInterval: 10.0
    )
    
    request.httpMethod = "GET"
    let session = URLSession.shared

    let dataTask = session.dataTask(
        with: request as URLRequest,
        completionHandler: {
            (data, response, error) -> Void in
                if let error = error {
                    completion(nil, error.localizedDescription);
                    return;
                }
            
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(CoronaStats.self, from: data)
                        completion(response, nil);
                    } catch let error {
                        completion(nil, error.localizedDescription);
                        print(error)
                    }
                }
        }
    );
    
    dataTask.resume()
}
