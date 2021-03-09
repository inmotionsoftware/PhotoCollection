//
//  ParameterEncoding.swift
//
//  Created by Thomas Woodfin on 03/07/21.
//

import Foundation

extension CharacterSet {
    
    static let networkURLQueryAllowed: CharacterSet = {
        let encodableDelimiters = CharacterSet(charactersIn: ":#[]@!$&'()*+,;=")
        let allowedCharacterSet = CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
        return allowedCharacterSet
    }()
}

class ParameterEncoding {
    
    class func formatRequestParameters(request: URLRequest, parameters: [String: AnyHashable]?) -> URLRequest {
        var request = request
        guard let parameters = parameters else {
            return request
        }
        if request.httpMethod == RequestConfiguration.HTTPMethod.get.rawValue {
            var parametersString = httpParametersString(parameters: parameters)
            
            if !parametersString.isEmpty {
                parametersString = "?" + parametersString
            }
            if let url = request.url {
                let urlStringWithParameters = url.absoluteString + parametersString
                if let urlWithParameters = URL(string: urlStringWithParameters) {
                    request.url = urlWithParameters
                }
            }
        } else if request.httpMethod == RequestConfiguration.HTTPMethod.post.rawValue || request.httpMethod == RequestConfiguration.HTTPMethod.put.rawValue {
            let parametersString = httpParametersString(parameters: parameters)
            request.httpBody = parametersString.data(using: .utf8)
        }
        return request
    }
    
    class func urlEncode(string: String) -> String {
        var urlEncodedString = ""
        if let encodedString = string.addingPercentEncoding(withAllowedCharacters: .networkURLQueryAllowed) {
            urlEncodedString = encodedString
        }
        return urlEncodedString
    }
    
    class func httpParametersString(parameters: [String: AnyHashable]) -> String {
        var parametersString = ""
        let parameterKeys = Array(parameters.keys)
        for index in 0..<parameterKeys.count {
            let parameterKey = parameterKeys[index]
            if let parameterValue = parameters[parameterKey] {
                let encodedParameterKey = urlEncode(string: parameterKey)
                let encodedParameterValue = urlEncode(string: "\(parameterValue)")
                parametersString = "\(parametersString)\(encodedParameterKey)=\(encodedParameterValue)"
                
                if index + 1 < parameterKeys.count {
                    parametersString.append("&")
                }
            }
        }
        return parametersString
    }
}
