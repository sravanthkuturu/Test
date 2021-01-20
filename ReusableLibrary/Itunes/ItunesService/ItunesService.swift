//
//  ItunesService.swift
//  ReusableLibrary
//
//  Created by Sravanth Kuturu on 20/01/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import Foundation


enum ItunesServiceAPIError {
    case buildableError
    
    var errorMessage: String {
        switch self {
        case .buildableError: return "Error in forming buildable"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .buildableError: return 400
        }
    }
}

//https://itunes.apple.com/lookup?id=909253

class ItunesService: NSObject {
    
    public static let shared = ItunesService()
    private override init() {}
    var apiBuildable: APIBuildable?
    var baseURL: String?
    
    func processItunesServiceAPIRequest(
        baseURL: String,
        id: String,
        urlSession: URLSessionProtocol = URLSession.shared,
        completion: @escaping ((ItunesAPIModel?, AppAPIServiceError?) -> Void)) {
        
        let client = AppHttpClient(urlSession)
        
        self.apiBuildable = APIBuildable.urlRequest(baseURL: baseURL, id: id)
        
        guard let buildable = self.apiBuildable else {
            completion(nil, AppAPIServiceError(message: ItunesServiceAPIError.buildableError.errorMessage, errorCode: ItunesServiceAPIError.buildableError.errorCode))
            
            return
        }
        
        client.processAPIRequest(buildable, type: ItunesAPIModel.self) { (serviceResult) in
            switch serviceResult {
            case .success(let model):
                completion(model, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
