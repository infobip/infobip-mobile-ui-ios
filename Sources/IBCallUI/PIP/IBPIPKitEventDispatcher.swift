//
//  IBPIPKitEventDispatcher.swift
//  InfobipMobileUI
//
//  Derived from PIPKit by Taeun Kim (MIT License)
//  Adapted for InfobipMobileUI — prefix changed from MM to IB.
//
//  Copyright © 2026 Infobip Ltd. All rights reserved.
//

import Foundation
import UIKit

final class IBPIPKitEventDispatcher {

    var pipPosition: IBPIPPosition

    private var window: UIWindow? { rootViewController?.view.window }
    private weak var rootViewController: IBPIPKitViewController?
    private lazy var transitionGesture = UIPanGestureRecognizer(target: self, action: #selector(onTransition(_:)))

    private var startOffset: CGPoint = .zero
    private var deviceNotificationObserver: NSObjectProtocol?
    private var windowSubviewsObservation: NSKeyValueObservation?

    deinit {
        windowSubviewsObservation?.invalidate()
        deviceNotificationObserver.flatMap { NotificationCenter.default.removeObserver($0) }
    }

    init(rootViewController: IBPIPKitViewController) {
        self.rootViewController = rootViewController
        self.pipPosition = rootViewController.initialPosition

        commonInit()
        updateFrame()

        switch rootViewController.initialState {
        case .full: didEnterFullScreen()
        case .pip: didEnterPIP()
        }
    }

    func enterFullScreen() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.updateFrame()
        }, completion: { [weak self] _ in
            self?.didEnterFullScreen()
        })
    }

    func enterPIP() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.updateFrame()
        }, completion: { [weak self] _ in
            self?.didEnterPIP()
        })
    }

    func updateFrame() {
        guard let window, let rootViewController else { return }
        switch IBPIPKit.state {
        case .full:
            rootViewController.view.frame = window.bounds
        case .pip:
            updatePIPFrame()
        default:
            break
        }
        rootViewController.view.setNeedsLayout()
        rootViewController.view.layoutIfNeeded()
    }

    // MARK: - Private

    private func commonInit() {
        rootViewController?.view.addGestureRecognizer(transitionGesture)

        if let shadow = rootViewController?.pipShadow {
            rootViewController?.view.layer.shadowColor = shadow.color.cgColor
            rootViewController?.view.layer.shadowOpacity = shadow.opacity
            rootViewController?.view.layer.shadowOffset = shadow.offset
            rootViewController?.view.layer.shadowRadius = shadow.radius
        }

        if let corner = rootViewController?.pipCorner {
            rootViewController?.view.layer.cornerRadius = corner.radius
            if let curve = corner.curve {
                rootViewController?.view.layer.cornerCurve = curve
            }
        }

        deviceNotificationObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            UIView.animate(withDuration: 0.15) { self?.updateFrame() }
        }

        windowSubviewsObservation = window?.observe(\.subviews, options: [.initial, .new]) { [weak self] window, _ in
            guard let rootViewController = self?.rootViewController else { return }
            window.bringSubviewToFront(rootViewController.view)
        }
    }

    private func didEnterFullScreen() {
        transitionGesture.isEnabled = false
        rootViewController?.didChangedState(.full)
    }

    private func didEnterPIP() {
        transitionGesture.isEnabled = true
        rootViewController?.didChangedState(.pip)
    }

    private func updatePIPFrame() {
        guard let window, let rootViewController else { return }

        let pipSize = rootViewController.pipSize
        let pipEdgeInsets = rootViewController.pipEdgeInsets
        let edgeInsets = rootViewController.insetsPIPFromSafeArea ? window.safeAreaInsets : .zero
        var origin = CGPoint.zero

        switch pipPosition {
        case .topLeft:
            origin.x = edgeInsets.left + pipEdgeInsets.left
            origin.y = edgeInsets.top + pipEdgeInsets.top
        case .middleLeft:
            origin.x = edgeInsets.left + pipEdgeInsets.left
            let vh = (window.frame.height - (edgeInsets.top + edgeInsets.bottom)) / 3.0
            origin.y = edgeInsets.top + (vh * 2.0) - ((vh + pipSize.height) / 2.0)
        case .bottomLeft:
            origin.x = edgeInsets.left + pipEdgeInsets.left
            origin.y = window.frame.height - edgeInsets.bottom - pipEdgeInsets.bottom - pipSize.height
        case .topRight:
            origin.x = window.frame.width - edgeInsets.right - pipEdgeInsets.right - pipSize.width
            origin.y = edgeInsets.top + pipEdgeInsets.top
        case .middleRight:
            origin.x = window.frame.width - edgeInsets.right - pipEdgeInsets.right - pipSize.width
            let vh = (window.frame.height - (edgeInsets.top + edgeInsets.bottom)) / 3.0
            origin.y = edgeInsets.top + (vh * 2.0) - ((vh + pipSize.height) / 2.0)
        case .bottomRight:
            origin.x = window.frame.width - edgeInsets.right - pipEdgeInsets.right - pipSize.width
            origin.y = window.frame.height - edgeInsets.bottom - pipEdgeInsets.bottom - pipSize.height
        }

        rootViewController.view.frame = CGRect(origin: origin, size: pipSize)
    }

    private func updatePIPPosition() {
        guard let window, let rootViewController else { return }

        let center = rootViewController.view.center
        let safeAreaInsets = window.safeAreaInsets
        let vh = (window.frame.height - (safeAreaInsets.top + safeAreaInsets.bottom)) / 3.0

        switch center.y {
        case let y where y < safeAreaInsets.top + vh:
            pipPosition = center.x < window.frame.width / 2.0 ? .topLeft : .topRight
        case let y where y > window.frame.height - safeAreaInsets.bottom - vh:
            pipPosition = center.x < window.frame.width / 2.0 ? .bottomLeft : .bottomRight
        default:
            pipPosition = center.x < window.frame.width / 2.0 ? .middleLeft : .middleRight
        }

        rootViewController.didChangePosition(pipPosition)
    }

    @objc private func onTransition(_ gesture: UIPanGestureRecognizer) {
        guard IBPIPKit.isPIP, let window, let rootViewController else { return }

        switch gesture.state {
        case .began:
            startOffset = rootViewController.view.center
        case .changed:
            let transition = gesture.translation(in: window)
            let pipSize = rootViewController.pipSize
            let pipEdgeInsets = rootViewController.pipEdgeInsets
            let edgeInsets = rootViewController.insetsPIPFromSafeArea ? window.safeAreaInsets : .zero

            var offset = startOffset
            offset.x += transition.x
            offset.y += transition.y
            offset.x = max(
                edgeInsets.left + pipEdgeInsets.left + pipSize.width / 2.0,
                min(offset.x, window.frame.width - edgeInsets.right - pipEdgeInsets.right - pipSize.width / 2.0)
            )
            offset.y = max(
                edgeInsets.top + pipEdgeInsets.top + pipSize.height / 2.0,
                min(offset.y, window.frame.height - edgeInsets.bottom - pipEdgeInsets.bottom - pipSize.height / 2.0)
            )
            rootViewController.view.center = offset
        case .ended:
            updatePIPPosition()
            UIView.animate(withDuration: 0.15) { [weak self] in self?.updatePIPFrame() }
        default:
            break
        }
    }
}

// MARK: - Setup

extension IBPIPUsable where Self: UIViewController {
    func setupEventDispatcher() {
        ibPipEventDispatcher = IBPIPKitEventDispatcher(rootViewController: self)
    }
}
