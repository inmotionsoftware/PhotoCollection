//
//  RequestConfiguration.swift
//
//  Created by Thomas Woodfin on 03/07/21.
//

import Foundation

typealias GenerateRequestConfiguration = (Result<URLRequest, Error>) -> Void

protocol RequestConfigurationProtocol {
    
    var endpoint: String { get }
    var httpMethod: RequestConfiguration.HTTPMethod { get }
    var parameters: [String: AnyHashable]? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeoutInterval: TimeInterval { get }
    var requestHeaders: [String: String]? { get }
    
    func generateRequest(completion: @escaping GenerateRequestConfiguration)
}

class RequestConfiguration: RequestConfigurationProtocol {
    
    enum HTTPMethod: String {
        
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case head = "HEAD"
    }
    
    let endpoint: String
    let httpMethod: RequestConfiguration.HTTPMethod
    let parameters: [String : AnyHashable]?
    let cachePolicy: URLRequest.CachePolicy
    let timeoutInterval: TimeInterval
    let requestHeaders: [String : String]?
    
    init(endpoint: String, httpMethod: HTTPMethod, parameters: [String: AnyHashable]? = nil, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 60, requestHeaders: [String: String]? = nil) {
        self.endpoint = endpoint
        self.httpMethod = httpMethod
        self.parameters = parameters
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        self.requestHeaders = requestHeaders
    }
    
    func generateRequest(completion: @escaping GenerateRequestConfiguration) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = cachePolicy
        request.httpMethod = httpMethod.rawValue
        request.timeoutInterval = timeoutInterval
        
        if let parameters = parameters {
            request = ParameterEncoding.formatRequestParameters(request: request, parameters: parameters)
        }
        
        if let requestHeaders = requestHeaders {
            for (key, value) in requestHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        completion(.success(request))
    }
}
