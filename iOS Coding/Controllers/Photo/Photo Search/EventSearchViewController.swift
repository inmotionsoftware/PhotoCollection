//
//  EventSearchViewController.swift
//
//  Created by Thomas Woodfin on 1/24/21.
//

import UIKit

protocol EventSearchViewControllerDelegate: class {
    
    func didSelectPhoto(_ photo: Photo)
}

class PhotosSearchViewController: UIViewController {
    
    enum State {
        case start
        case empty
        case loading
        case events
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    weak var delegate: EventSearchViewControllerDelegate?

    private let searchController: UISearchController
    
    private var photos = [Photo]()
    private var selectedPhoto: Photo?

    private let networkManager = NetworkManager()
    private var photoRepository : PhotoRepository?

    
    init() {

        searchController = UISearchController(searchResultsController: nil)
        photoRepository = PhotoRepository(networkManager: networkManager)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func configureUI() {

        title = NSLocalizedString("Photos Collection", comment: "")
        extendedLayoutIncludesOpaqueBars = true
        
        tableView.register(UINib(nibName: String(describing: EventSearchCell.self), bundle: nil), forCellReuseIdentifier: String(describing: EventSearchCell.self))
        tableView.keyboardDismissMode = .onDrag
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search Photos", comment: "")
        searchController.searchBar.tintColor = UIColor(named: "searchBarTint")
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [.foregroundColor: UIColor(named: "searchBarText") ?? .white]
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
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
            actionLabel.text = NSLocalizedString("No events found.", comment: "")
        case .events:
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

    func presentAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension PhotosSearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if let eventSearchCell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventSearchCell.self), for: indexPath) as? EventSearchCell {
            let event = photos[indexPath.row]
            eventSearchCell.configureData(photo: event)
            cell = eventSearchCell
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PhotosSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectPhoto(photos[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension PhotosSearchViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        self.setState(state: .loading)
        photoRepository!.fetchPhotos(completion: { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self.setState(state: events.isEmpty ? PhotosSearchViewController.State.empty: .events)
                    self.setPhotos(photos: self.photos)
                case .failure(let error):
                    self.setState(state: .empty)
                    self.presentAlert(title: NSLocalizedString("Event Error", comment: ""), message: error.localizedDescription)
                }
            }
        })
    }
}
