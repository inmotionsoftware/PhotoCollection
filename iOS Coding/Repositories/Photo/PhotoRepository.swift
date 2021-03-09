//
//  PhotoRepository.swift
//
//  Created by Thomas Woodfin on 03/07/21.
//

import Foundation

typealias PhotoRepositoryCompletion = (Result<[Photo], Error>) -> Void

class PhotoRepository {
    
    var networkDataSource: PhotoDataSource
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        
        networkDataSource = PhotoNetworkDataSource(networkManager: networkManager)
    }
    
    func fetchPhotos(completion: PhotoRepositoryCompletion?) {
        networkDataSource.fetchPhotos() { result in
            switch result {
            case .success(let items):
                completion?(.success(items))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
