//
//  DataResponse.swift
//
//  Created by Thomas Woodfin on 03/07/21.
//

import Foundation

struct DataResponse<T> {
    
    let data: T?
    let urlResponse: URLResponse?
    
    init(data: T?, urlResponse: URLResponse?) {
        self.data = data
        self.urlResponse = urlResponse
    }
}
