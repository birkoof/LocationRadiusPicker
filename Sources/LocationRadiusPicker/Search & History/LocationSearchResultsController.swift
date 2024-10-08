//
//  LocationSearchResultsController.swift
//
//
//  Created by Eman Basic on 28.09.24.
//

import UIKit
import MapKit

final class LocationSearchResultsController: UITableViewController {
    
    // MARK: - Private properties
    
    private let previouslySearchedText: String
    
    // MARK: - Public properties
    
    var locations: [LocationModel] = []
    var onSelectLocation: ((_ location: LocationModel) -> Void)?
    var onDeleteLocation: ((_ location: LocationModel) -> Void)?
    var isShowingHistory = false
    
    // MARK: - Init
    
    init(previouslySearchedText: String) {
        self.previouslySearchedText = previouslySearchedText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

// MARK: - Setup

extension LocationSearchResultsController {
    private func setup() {
        extendedLayoutIncludesOpaqueBars = true
        
        tableView.register(cell: LocationSearchResultCell.self)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .secondarySystemBackground
        
        if previouslySearchedText.isEmpty {
            tableView.contentInset.top = 10
        }
    }
}

// MARK: - Table view
    
extension LocationSearchResultsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isShowingHistory && !locations.isEmpty ? previouslySearchedText : nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(for: LocationSearchResultCell.self, with: indexPath)
        cell.update(locationName: locations[indexPath.row].name, locationSubtitle: locations[indexPath.row].address)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectLocation?(locations[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 else { return nil }
        guard onDeleteLocation != nil else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            if let location = self?.locations[indexPath.row] {
                self?.onDeleteLocation?(location)
                self?.locations.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completion(true)
                return
            }
            
            completion(false)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        deleteAction.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.0)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
