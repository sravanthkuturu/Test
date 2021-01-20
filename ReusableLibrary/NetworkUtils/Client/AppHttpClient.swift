//
//  AppHttpClient.swift
//
//  Created by Sravanth Kuturu
//

import Foundation

protocol URLSessionDataTaskProtocol {
    func resume()
}

protocol URLSessionProtocol {
    typealias DataTaskCompletion = (_  data: Data?, _ response: URLResponse?, _ error: Error?) -> Void
    
    func dataTask(_ urlRequest: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }

extension URLSession: URLSessionProtocol {
    func dataTask(_ urlRequest: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        // Below method is the inbuilt method of the URLSession class.
        // We have kept the method signature same as the URLSession class.
        let task = dataTask(with: urlRequest, completionHandler: completionHandler) as URLSessionDataTaskProtocol
        return task
    }
}

class AppHttpClient {
    
    typealias CompletionClosure<T: Codable> = (AppAPIResult<T>) -> Void
    
    let session: URLSessionProtocol
    // Dependency Injection of the Session Protocol
    init(_ session: URLSessionProtocol) {
        self.session = session
    }
    
    /// Processing API
    /// - Parameters:
    ///   - buildable: Enum of buildable type which forms the URLRequest
    ///   - type: Codable Object of the expected response
    ///   - completion: Closure call back which return an enum with success and error cases
    func processAPIRequest<T: Codable>(_ buildable: Buildable,
                                       type: T.Type,
                                       completion: @escaping CompletionClosure<T>) {
        guard let urlRequest = buildable.build() else {
            let error = AppAPIServiceError(message: AppAPIError.buildableFailure.value, errorCode: nil)
            completion(.failure(error))
            return
        }
        
        let dataTask = self.session .dataTask(urlRequest) { (data, response, error) in
            
            guard let data = data,
                error == nil else {
                    let error = AppAPIServiceError(message: AppAPIError.noData.value, errorCode: nil)
                    
                    completion(.failure(error))
                    return
            }
            
            _ = self.printRequestResponse(request: urlRequest, data: data)
            
            
            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200  {
                do {
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                        let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                        let jsonString = String(bytes: prettyPrintedData, encoding: .ascii) {
                        print(jsonString)
                    }
                    
                    let model = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(model))
                } catch let e {
                    let error: AppAPIServiceError = {
                        if let httpResponse = response as? HTTPURLResponse {
                            return AppAPIServiceError(message: e.localizedDescription, errorCode: httpResponse.statusCode)
                            
                        }
                        return AppAPIServiceError(message: e.localizedDescription, errorCode: nil)
                    }()
                    
                    completion(.failure(error))
                }
                
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    let error: AppAPIServiceError = {
                        switch httpResponse.statusCode {
                        case 400: return AppAPIServiceError(message: "Bad Request", errorCode: httpResponse.statusCode)
                        case 404: return AppAPIServiceError(message: "Resource Information Unavailable", errorCode: httpResponse.statusCode)
                        case 500: return AppAPIServiceError(message: "Internal Server Error", errorCode: httpResponse.statusCode)
                        default:
                            return AppAPIServiceError(message: "Generic Error", errorCode: httpResponse.statusCode)
                        }
                        
                    }()
                    completion(.failure(error))
                } else {
                    let noResponseError =  AppAPIServiceError(message: "No Response from server", errorCode: nil)
                    completion(.failure(noResponseError))
                }
            }
            
        }
        dataTask.resume()
    }
}

extension AppHttpClient {
    
    func printRequestResponse(request: URLRequest, data: Data? = nil) -> (requestLog:Bool, responseLog: Bool) {
        
        print("======================= Request Starts =======================")
        if let urlAsString = request.url?.absoluteURL {
            print("URL: \(urlAsString)")
        }
        
        if let method = request.httpMethod {
            print("\nMethod: \(method)")
        }
        
        if let headerParams = request.allHTTPHeaderFields {
            print("\nHeader Params: ")
            print(headerParams)
        }
        if let dataParams = request.httpBody {
            print("\n HTTP Body: ")
            if let jsonBodyString = String(bytes: dataParams, encoding: .ascii) {
                print(jsonBodyString)
            }
        }
        print("====================== Request Ends =========================")
        print("====================== Response Starts ======================")
        guard let data = data else {
            print("\n No Response Data: ")
            print("================== Response Ends ===========================")
            return  (true, false)
        }
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
            let jsonString = String(bytes: prettyPrintedData, encoding: .ascii) {
            print(jsonString)
            //TODO: Remove this notification once certification is complete.
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CertResponse"), object: nil, userInfo: ["response":jsonString])
        }
        
        print("================== Response Ends ===========================")
        return (true, true)
    }
}




