//
//  PhotoDataSource.swift
//
//  Created by Thomas Woodfin on 03/07/21.
//

import Foundation

typealias PhotoDataSourceCompletion = (Result<[Photo], Error>) -> Void

protocol PhotoDataSource {
    
    func fetchPhotos(completion: PhotoDataSourceCompletion?)
}
