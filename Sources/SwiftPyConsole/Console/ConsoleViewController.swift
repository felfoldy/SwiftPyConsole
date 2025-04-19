//
//  ConsoleViewController.swift
//  SwiftPyConsole
//
//  Created by Tibor Felföldy on 2025-03-18.
//

#if canImport(UIKit) && !os(visionOS)
import UIKit

open class PythonConsoleViewController: UIViewController {
    private var baseViewController: UIViewController
    
    public init(base: UIViewController) {
        baseViewController = base
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // Add baseViewController.
        addChild(baseViewController)
        view.addSubview(baseViewController.view)
        baseViewController.didMove(toParent: self)
        baseViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            baseViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            baseViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            baseViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            baseViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Set sheet.
        guard let sheet = sheetPresentationController else {
            return
        }
        
        sheet.detents = [.medium(), .large()]
        sheet.largestUndimmedDetentIdentifier = .medium
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        sheet.prefersEdgeAttachedInCompactHeight = true
        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        sheet.prefersGrabberVisible = !(baseViewController is UINavigationController)
    }
}
#endif
