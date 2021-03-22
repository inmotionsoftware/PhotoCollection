//
//  PhotoCell.swift
//
//  Created by Thomas Woodfin on 03/07/21.
//

import Kingfisher
import UIKit

class PhotoCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.layer.cornerRadius = 10
    }
    
    func configureData(photo: Photo) {

        if let imageString = photo.thumbnailUrl, let url = URL(string: imageString) {
            photoImageView.kf.setImage(with: url)
        } else {
            photoImageView.image = nil
        }
        photoTitleLabel.text = photo.title
    }
}
