//
//  ReusableLibraryTests.swift
//  ReusableLibraryTests
//
//  Created by Sravanth Kuturu on 20/01/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import XCTest
@testable import ReusableLibrary

class ReusableLibraryTests: XCTestCase {
    
    var httpClient: AppHttpClient?
    var mockSession: MockURLSesion?
    
    
    override func setUp() {
        mockSession = MockURLSesion()
        self.httpClient = AppHttpClient(mockSession!)
    }
    
    func testItunesSuccessBuildable() {
        let buildable = APIBuildable.urlRequest(baseURL: AppConstant.baseURL, id: "1234")
        XCTAssertEqual(buildable.endPoint, "/lookup?id=1234")
        XCTAssert(buildable.methodType == .post)
        XCTAssertNil(buildable.requestBody)
        XCTAssertEqual(buildable.headers, [:])
    }
    
    func testItunesAPISuccessResponse() {
        
        let buildable = APIBuildable.urlRequest(baseURL: AppConstant.baseURL, id: "1234")
        XCTAssertEqual(buildable.endPoint, "/lookup?id=1234")
        XCTAssert(buildable.methodType == .post)
        XCTAssertNil(buildable.requestBody)
        
        self.mockSession?.nextData = JSONUtility.jsonData(with: "success_response")
        
        self.httpClient?.processAPIRequest(buildable, type: ItunesAPIModel.self, completion: { (serviceResult) in
            switch(serviceResult) {
            case .success(let model):
                XCTAssertNotNil(model)
            case .failure(_):
                break
            }
        })
        
        let resume = self.mockSession!.nextDataTask.resumeWasCalled
        XCTAssertEqual(resume, true)
    }
    
    func testItunesAPIFailureResponse() {
        
        let buildable = APIBuildable.urlRequest(baseURL: AppConstant.baseURL, id: "")
        XCTAssertEqual(buildable.endPoint, "/lookup?id=")
        XCTAssert(buildable.methodType == .post)
        XCTAssertNil(buildable.requestBody)
        
        self.mockSession?.nextData = JSONUtility.jsonData(with: "failure_response")
        
        self.httpClient?.processAPIRequest(buildable, type: ItunesAPIModel.self, completion: { (serviceResult) in
            switch(serviceResult) {
            case .success(let model):
                XCTAssertNotNil(model)
                XCTAssertEqual(model.resultCount!, 0)
            case .failure(_):
                break
            }
        })
        
        let resume = self.mockSession!.nextDataTask.resumeWasCalled
        XCTAssertEqual(resume, true)
    }
    
}
