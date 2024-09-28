//
//  UITableView+Extension.swift
//
//
//  Created by Eman Basic on 28.09.24.
//

import UIKit

extension UITableView {
    private func reuseIdentifier<T>(for type: T.Type) -> String {
        return String(describing: type)
    }

    func register<T: UITableViewCell>(cell: T.Type) {
        register(T.self, forCellReuseIdentifier: reuseIdentifier(for: cell))
    }

    func dequeueCell<T: UITableViewCell>(for type: T.Type, with indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: reuseIdentifier(for: type), for: indexPath) as? T else {
            fatalError("Failed to dequeue cell.")
        }

        return cell
    }
}
