//
//  URLRequest.swift
//  
//
//  Created by MarKinho on 26/07/2024.
//

import Foundation

extension URLRequest {
    func log() -> String {
        var logOutput = "\n - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"
        
        let urlString = self.url?.absoluteString ?? "N/A"
        let method = self.httpMethod ?? "N/A"
        logOutput += "\(method) \(urlString) \n"
        
        if let headers = self.allHTTPHeaderFields {
            logOutput += "Headers:\n"
            for (key, value) in headers {
                logOutput += "\(key): \(value)\n"
            }
        }
        
//        if let body = self.httpBody {
//            let bodyString = String(data: body, encoding: .utf8) ?? "Cannot decode body data"
//            logOutput += "Body:\n\(bodyString)\n"
//        }
        
        logOutput += " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"
        
        return logOutput
    }
}
