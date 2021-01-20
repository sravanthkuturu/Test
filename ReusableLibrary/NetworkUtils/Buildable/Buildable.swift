/*
 *    Buildable.swift
 *    Created by Sravanth Kuturu 
 */

import UIKit

// MARK: - Definitions -

enum AppApiTimeinterval {
    case sixty
    case ninty
    
    var value: TimeInterval {
        switch self {
        case .sixty: return TimeInterval(60)
        case .ninty: return TimeInterval(90)
        }
    }
}

enum AppHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    
    var value: String {
        return self.rawValue
    }
}

// MARK: - Type -
protocol Buildable {
    var endPoint: String { get }
    var methodType: AppHTTPMethod { get }
    var headers: [String: String] { get }
    var requestBody: [String: Any]? { get }
    var baseUrl: String { get }
    var url: URL? { get }
    func build() -> URLRequest?
}

extension Buildable {
    
    var url: URL? {
        // Construct Autopay enrollment path from baseURL
        let finalPath = self.baseUrl + endPoint

        // Return URL type
        guard let url = URL(string: finalPath) else { return nil }
        return url
    }
    
    
    func build() -> URLRequest? {
        guard let url = url else {
            return nil
        }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: AppApiTimeinterval.sixty.value)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = methodType.rawValue
        if let params = requestBody {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch {
                return nil
            }
        }
        
        print("============== CURL is========")
        print(urlRequest.cURL)
        print("============== CURL Ends========")
        return urlRequest
    }
    
}

extension URLRequest {
    
    /// Returns a cURL command for a request
    /// - return A String object that contains cURL command or "" if an URL is not properly initalized.
    var cURL: String {
        
        guard
            let url = url,
            let httpMethod = httpMethod,
            url.absoluteString.utf8.count > 0
            else {
                return ""
        }
        
        var curlCommand = "curl \\\n"
        
        // URL
        curlCommand = curlCommand.appendingFormat(" '%@' \\\n", url.absoluteString)
        
        // HTTP Method
        curlCommand = curlCommand.appendingFormat(" -X %@ \\\n", httpMethod)
        
        // Headers
        let allHeadersFields = allHTTPHeaderFields!
        let allHeadersKeys = Array(allHeadersFields.keys)
        let sortedHeadersKeys  = allHeadersKeys.sorted(by: <)
        for key in sortedHeadersKeys {
            curlCommand = curlCommand.appendingFormat(" -H '%@: %@' \\\n", key, self.value(forHTTPHeaderField: key)!)
        }
        
        // HTTP body
        if let httpBody = httpBody, httpBody.count > 0 {
            let httpBodyString = String(data: httpBody, encoding: String.Encoding.utf8)!
            let escapedHttpBody = escapeAllSingleQuotes(httpBodyString)
            curlCommand = curlCommand.appendingFormat(" --data '%@' \\\n", escapedHttpBody)
        }
        
        return curlCommand
    }
    
    /// Escapes all single quotes for shell from a given string.
    private func escapeAllSingleQuotes(_ value: String) -> String {
        return value.replacingOccurrences(of: "'", with: "'\\''")
    }
}
