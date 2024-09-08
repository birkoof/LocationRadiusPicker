//
//  ViewController.swift
//  LocationRadiusPickerDemo
//
//  Created by Eman Basic on 08.09.24.
//

import LocationRadiusPicker
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var openPickerButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = .systemBlue
        config.title = "Open picker"
        
        let view = UIButton(configuration: config)
        view.addAction(UIAction { [unowned self] _ in
            onOpenPickerButtonPressed()
        }, for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
     
        setup()
    }
}

// MARK: - Setup

extension ViewController {
    private func setup() {
        view.addSubview(openPickerButton)
        
        NSLayoutConstraint.activate([
            openPickerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openPickerButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Action

extension ViewController {
    private func onOpenPickerButtonPressed() {
        present(LocationRadiusPickerController(), animated: true)
    }
}
