//
//  APIBuildable.swift
//  ReusableLibrary
//
//  Created by Sravanth Kuturu on 20/01/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import Foundation

enum APIBuildable: Buildable {
    
    case urlRequest(baseURL: String, id: String)
    
    var endPoint: String {
        switch self {
        case .urlRequest(_, let id):
            return "/lookup?id=" + id
        }
        
    }
    
    var version: String {
        switch  self {
        case .urlRequest:
            return "v3"
        }
    }
    
    var methodType: AppHTTPMethod {
        switch  self {
        case .urlRequest:
            return .post
        }
    }
    
    var headers: [String : String] {
        return [:]
    }
    
    var requestBody: [String : Any]? {
        return nil
    }
    
    var baseUrl: String {
        switch self {
        case .urlRequest(let baseURL, _):
            return baseURL
        }
    }
    
}
