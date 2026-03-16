//
//  IBPIPKit.swift
//  InfobipMobileUI
//
//  Derived from PIPKit by Taeun Kim (MIT License)
//  Adapted for InfobipMobileUI — prefix changed from MM to IB.
//
//  Copyright © 2026 Infobip Ltd. All rights reserved.
//

import Foundation
import UIKit

public struct IBPIPShadow {
    public let color: UIColor
    public let opacity: Float
    public let offset: CGSize
    public let radius: CGFloat

    public init(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        self.color = color
        self.opacity = opacity
        self.offset = offset
        self.radius = radius
    }
}

public struct IBPIPCorner {
    public let radius: CGFloat
    public let curve: CALayerCornerCurve?

    public init(radius: CGFloat, curve: CALayerCornerCurve? = nil) {
        self.radius = radius
        self.curve = curve
    }
}

public enum IBPIPState {
    case pip
    case full
}

public enum IBPIPPosition {
    case topLeft
    case middleLeft
    case bottomLeft
    case topRight
    case middleRight
    case bottomRight
}

enum IBPIPInternalState {
    case none
    case pip
    case full
    case exit
}

public typealias IBPIPKitViewController = (UIViewController & IBPIPUsable)

public final class IBPIPKit {

    static public var isActive: Bool { rootViewController != nil }
    static public var isPIP: Bool { state == .pip }
    static public var visibleViewController: IBPIPKitViewController? { rootViewController }

    static internal var state: IBPIPInternalState = .none
    static private var rootViewController: IBPIPKitViewController?
    static private var pipWindow: UIWindow?

    static var keyWindow: UIWindowScene? {
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState != .unattached }
            .sorted { $0.activationState.rawValue < $1.activationState.rawValue }
            .first
    }

    public class func show(with viewController: IBPIPKitViewController, completion: (() -> Void)? = nil) {
        guard !isActive else {
            dismiss(animated: false) {
                IBPIPKit.show(with: viewController, completion: completion)
            }
            return
        }

        guard let keyWindow = keyWindow else {
            completion?()
            return
        }

        let newWindow = IBPIPKitWindow(windowScene: keyWindow)
        newWindow.backgroundColor = .clear
        newWindow.rootViewController = viewController
        newWindow.windowLevel = .alert
        newWindow.makeKeyAndVisible()

        pipWindow = newWindow
        rootViewController = viewController
        rootViewController?.isInitiatedWithPIP = true
        state = (viewController.initialState == .pip) ? .pip : .full

        viewController.view.alpha = 0.0
        viewController.setupEventDispatcher()

        UIView.animate(withDuration: 0.25, animations: {
            IBPIPKit.rootViewController?.view.alpha = 1.0
        }) { _ in
            completion?()
        }
    }

    public class func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        state = .exit
        guard rootViewController != nil else { completion?(); return }
        rootViewController?.pipDismiss(animated: animated, completion: {
            IBPIPKit.reset()
            completion?()
        })
    }

    // MARK: - Internal

    class func startPIPMode() {
        guard let rootViewController else { return }
        state = .pip
        rootViewController.ibPipEventDispatcher?.enterPIP()
    }

    class func stopPIPMode() {
        guard let rootViewController else { return }
        state = .full
        rootViewController.ibPipEventDispatcher?.enterFullScreen()
    }

    // MARK: - Private

    private static func reset() {
        IBPIPKit.state = .none
        IBPIPKit.rootViewController = nil
        // Hiding the window removes it from UIWindowScene's retained windows list,
        // then clearing rootViewController lets CallController be deallocated.
        IBPIPKit.pipWindow?.rootViewController = nil
        IBPIPKit.pipWindow?.isHidden = true
        IBPIPKit.pipWindow = nil
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { !$0.isHidden }?
            .makeKeyAndVisible()
    }
}

// MARK: - Async/Await

extension IBPIPKit {
    public class func show(with viewController: IBPIPKitViewController) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                IBPIPKit.show(with: viewController) {
                    continuation.resume()
                }
            }
        }
    }

    public class func dismiss(animated: Bool) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                IBPIPKit.dismiss(animated: animated) {
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - Private window

private final class IBPIPKitWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let rootViewController else { return super.hitTest(point, with: event) }
        return rootViewController.view.frame.contains(point) ? super.hitTest(point, with: event) : nil
    }
}
