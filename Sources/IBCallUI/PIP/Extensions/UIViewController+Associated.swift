//
//  UIViewController+Associated.swift
//  InfobipMobileUI
//
//  Derived from PIPKit by Kofktu (MIT License)
//  Adapted for InfobipMobileUI.
//
//  Copyright © 2026 Infobip Ltd. All rights reserved.
//

import UIKit

extension UIViewController {

    private enum IBAssociatedKeys {
        static var ibPipEventDispatcher = "ib_pipEventDispatcher"
    }

    @MainActor internal var ibPipEventDispatcher: IBPIPKitEventDispatcher? {
        get {
            withUnsafePointer(to: &IBAssociatedKeys.ibPipEventDispatcher) {
                objc_getAssociatedObject(self, $0) as? IBPIPKitEventDispatcher
            }
        }
        set {
            withUnsafePointer(to: &IBAssociatedKeys.ibPipEventDispatcher) {
                objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
