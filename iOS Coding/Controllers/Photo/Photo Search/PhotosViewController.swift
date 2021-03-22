//
//  PhotosViewController.swift
//
//  Created by Thomas Woodfin on 03/07/21.
//

import UIKit
import IDMPhotoBrowser

protocol PhotosViewControllerDelegate: class {
    
    func didSelectPhoto(_ photo: Photo)
}

class PhotosViewController: UIViewController {
    
    enum State {
        case start
        case empty
        case loading
        case photos
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    weak var delegate: PhotosViewControllerDelegate?
    
    private var photos = [Photo]()
    private var selectedPhoto: Photo?

    private let networkManager = NetworkManager()
    private var photoRepository : PhotoRepository?

    
    init() {
        photoRepository = PhotoRepository(networkManager: networkManager)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func configureUI() {

        title = NSLocalizedString("Photos Collection", comment: "")
        extendedLayoutIncludesOpaqueBars = true
        
        tableView.register(UINib(nibName: String(describing: PhotoCell.self), bundle: nil), forCellReuseIdentifier: String(describing: PhotoCell.self))
        tableView.keyboardDismissMode = .onDrag
        
        setViewState(state: .start)
    }
    
    func setViewState(state: State) {
        switch state {
        case .start:
            tableView.isHidden = true
            loadingIndicator.isHidden = true
            actionLabel.isHidden = false
            actionLabel.text = NSLocalizedString("Nothing to display.", comment: "")
        case .loading:
            tableView.isHidden = true
            loadingIndicator.isHidden = false
            actionLabel.isHidden = true
        case .empty:
            tableView.isHidden = true
            loadingIndicator.isHidden = true
            actionLabel.isHidden = false
            actionLabel.text = NSLocalizedString("No photos found.", comment: "")
        case .photos:
            tableView.isHidden = false
            loadingIndicator.isHidden = true
            actionLabel.isHidden = true
        }
    }

    func setState(state: State) {
        setViewState(state: state)
    }

    func setPhotos(photos: [Photo]) {
        self.photos = photos
        tableView.reloadData()
    }

    func fetchPhotos() {
        self.setState(state: .loading)
        photoRepository!.fetchPhotos(completion: { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let photos):
                    self.setState(state: photos.isEmpty ? PhotosViewController.State.empty: .photos)
                    self.setPhotos(photos: photos)
                case .failure(let error):
                    self.setState(state: .empty)
                    self.presentAlert(title: NSLocalizedString("Photo Error", comment: ""), message: error.localizedDescription)
                }
            }
        })
    }

    func presentAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension PhotosViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if let photoCell = tableView.dequeueReusableCell(withIdentifier: String(describing: PhotoCell.self), for: indexPath) as? PhotoCell {
            let photo = photos[indexPath.row]
            photoCell.configureData(photo: photo)
            cell = photoCell
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PhotosViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var photoURLs : [String] = []
        photos.forEach { (photo) in
            photoURLs.append(photo.thumbnailUrl!)
        }
        
        if photoURLs.count > 0 {

            guard let browserPhotos = IDMPhotoBrowser(photoURLs: photoURLs) else { return }
            self.present(browserPhotos, animated: true, completion: nil)
        }
    }
}
