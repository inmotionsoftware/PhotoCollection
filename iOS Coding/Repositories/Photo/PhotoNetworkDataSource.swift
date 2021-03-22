//
//  PhotoNetworkDataSource.swift
//
//  Created by Thomas Woodfin on 03/07/21.
//

import Foundation

class PhotoNetworkDataSource: PhotoDataSource {
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchPhotos(completion: PhotoDataSourceCompletion?) {
        let requestConfiguration = RequestConfiguration(endpoint: "https://jsonplaceholder.typicode.com/photos", httpMethod: .get, parameters: nil)
        networkManager.executeRequest(requestConfiguration: requestConfiguration, responseModel: [Photo].self) { result in
            switch result {
            case .success(let dataResponse):
                if let photos = dataResponse.data as? [Photo] {
                    completion?(.success(photos))
                } else {
                    completion?(.success([]))
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
