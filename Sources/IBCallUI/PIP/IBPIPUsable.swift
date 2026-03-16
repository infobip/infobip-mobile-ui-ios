//
//  IBPIPUsable.swift
//  InfobipMobileUI
//
//  Derived from PIPKit by Taeun Kim (MIT License)
//  Adapted for InfobipMobileUI — prefix changed from MM to IB.
//
//  Copyright © 2026 Infobip Ltd. All rights reserved.
//

import Foundation
import UIKit

public protocol IBPIPUsable {
    var initialState: IBPIPState { get }
    var initialPosition: IBPIPPosition { get }
    var insetsPIPFromSafeArea: Bool { get }
    var pipEdgeInsets: UIEdgeInsets { get }
    var pipSize: CGSize { get }
    var pipShadow: IBPIPShadow? { get }
    var pipCorner: IBPIPCorner? { get }
    var isInitiatedWithPIP: Bool { get set }
    func didChangedState(_ state: IBPIPState)
    func didChangePosition(_ position: IBPIPPosition)
}

public extension IBPIPUsable {
    var initialState: IBPIPState { .pip }
    var initialPosition: IBPIPPosition { .bottomRight }
    var insetsPIPFromSafeArea: Bool { true }
    var pipEdgeInsets: UIEdgeInsets { UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15) }
    var pipSize: CGSize { CGSize(width: 200.0, height: (200.0 * 9.0) / 16.0) }
    var pipShadow: IBPIPShadow? { IBPIPShadow(color: .black, opacity: 0.3, offset: CGSize(width: 0, height: 8), radius: 10) }
    var pipCorner: IBPIPCorner? { IBPIPCorner(radius: 6, curve: .continuous) }
    func didChangedState(_ state: IBPIPState) {}
    func didChangePosition(_ position: IBPIPPosition) {}
}

public extension IBPIPUsable where Self: UIViewController {

    func setNeedsUpdatePIPFrame() {
        guard IBPIPKit.isPIP else { return }
        ibPipEventDispatcher?.updateFrame()
    }

    func startPIPMode() {
        IBPIPKit.startPIPMode()
    }

    func stopPIPMode() {
        IBPIPKit.stopPIPMode()
    }
}

internal extension IBPIPUsable where Self: UIViewController {

    func pipDismiss(animated: Bool, completion: (() -> Void)?) {
        if animated {
            UIView.animate(
                withDuration: 0.24,
                delay: 0,
                options: .curveEaseOut,
                animations: { [weak self] in
                    self?.view.alpha = 0.0
                    self?.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                },
                completion: { [weak self] _ in
                    self?.view.removeFromSuperview()
                    completion?()
                }
            )
        } else {
            view.removeFromSuperview()
            completion?()
        }
    }
}
