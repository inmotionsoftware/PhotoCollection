//
//  Photo.swift
//
//  Created by Thomas Woodfin on 03/07/21.
//

import Foundation

struct Photo: Codable & Hashable {

    let id: Int
    let albumId: Int
    let title: String?
    let url: String?
    let thumbnailUrl: String?
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
