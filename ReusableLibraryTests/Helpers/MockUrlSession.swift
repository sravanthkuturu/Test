//
//  MockUrlSession.swift
//

import XCTest
@testable import ReusableLibrary

class MockURLSesion: URLSessionProtocol {
    var lastUrl: URL? // This variable will be used to compare the passed URL of the URL request
    var nextData: Data? // this will be passed from the Test function on the basis of the success and failure test cases of the response.
    var nextError: Error? // This error message will be passed on the basis of success and failure testing of the response.
    
    var nextDataTask = MockURLSessionDataTask() // Every time a new data task will be created for making the API call.
    
    func successResponse(_ urlRequest: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: urlRequest.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
    func dataTask(_ urlRequest: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        lastUrl = urlRequest.url
        completionHandler(nextData, successResponse(urlRequest), nextError )
        return nextDataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    var resumeWasCalled = false
    func resume() {
        resumeWasCalled = true
    }
}

