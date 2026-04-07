//
//  IBCallButtonsSheet.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI

/// A bottom-anchored sheet that shows the first N buttons in a row, and the
/// remaining buttons as a scrollable list above. The sheet can be dragged up
/// to reveal the overflow list, or back down to hide it.
struct IBCallButtonsSheet: View {
    @Binding var buttons: [IBCallButtonModel]
    var configuration: IBCallUIConfiguration
    var maxVisibleInRow: Int = 4

    /// Drag offset used to interactively reveal / hide the overflow section.
    @State private var dragOffset: CGFloat = 0
    /// Whether the overflow section is fully expanded.
    @State private var isExpanded: Bool = false

    private var visibleButtons: [IBCallButtonModel] {
        Array(buttons.prefix(maxVisibleInRow))
    }

    private var overflowButtons: [IBCallButtonModel] {
        guard buttons.count > maxVisibleInRow else { return [] }
        return Array(buttons.dropFirst(maxVisibleInRow))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            dragIndicator

            // Visible row — always shown
            IBCallButtonsRow(
                buttons: Binding(
                    get: { Array(buttons.prefix(maxVisibleInRow)) },
                    set: { newValues in
                        for (i, val) in newValues.enumerated() where i < buttons.count {
                            buttons[i] = val
                        }
                    }
                ),
                maxVisible: maxVisibleInRow
            )
            .padding(.vertical, 16)

            // Overflow list — revealed when expanded
            if !overflowButtons.isEmpty && isExpanded {
                Divider()
                    .background(configuration.sheetDividerColor)
                    .padding(.horizontal, 51)

                overflowList
            }

            // Extra bottom spacing to keep buttons above the safe-area gesture zone
            Spacer().frame(height: 16)
        }
        .frame(maxWidth: .infinity)
        .background(configuration.sheetBackgroundColor)
        .ibCornerRadius(18, corners: [.topLeft, .topRight])
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { value in
                    let delta = -value.translation.height
                    dragOffset = max(0, delta)
                }
                .onEnded { value in
                    let delta = -value.translation.height
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded = delta > 30 ? true : (delta < -20 ? false : isExpanded)
                        dragOffset = 0
                    }
                }
        )
    }

    private var dragIndicator: some View {
        Capsule()
            .fill(configuration.sheetDragIndicatorColor)
            .frame(width: 36, height: 4)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    private var overflowList: some View {
        VStack(spacing: 0) {
            ForEach(
                Array(buttons.dropFirst(maxVisibleInRow).enumerated()),
                id: \.element.id
            ) { index, item in
                overflowRow(
                    button: item,
                    bindingIndex: maxVisibleInRow + index
                )
            }
        }
        .padding(.horizontal, 51)
        .padding(.vertical, 4)
        // Cap height so the sheet never grows beyond ~4 rows
        .frame(maxHeight: CGFloat(overflowButtons.count) * 46)
    }

    private func overflowRow(button: IBCallButtonModel, bindingIndex: Int) -> some View {
        let model = buttons[bindingIndex]
        let isSelected = model.isSelected
        let icon = isSelected ? (model.selectedIcon ?? model.icon) : model.icon
        let circleBg = isSelected
            ? (model.selectedBackgroundColor ?? model.backgroundColor)
            : model.backgroundColor
        let iconFg = isSelected ? (model.selectedIconColor ?? model.iconColor) : model.iconColor
        let circleSize: CGFloat = 30

        return Button(action: {
            buttons[bindingIndex].onTap()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(circleBg)
                        .frame(width: circleSize, height: circleSize)
                    icon
                        .resizable()
                        .scaledToFit()
                        .padding(7)
                        .frame(width: circleSize, height: circleSize)
                        .foregroundColor(iconFg)
                }

                Text(button.label ?? "")
                    .foregroundColor(configuration.rowActionLabelColor)
                    .font(.body)
                Spacer()
            }
            .frame(height: 38)
        }
        .disabled(!model.isEnabled)
        .opacity(model.isEnabled ? 1.0 : 0.4)
    }
}

// MARK: - Corner radius helper

private extension View {
    func ibCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(IBRoundedCorner(radius: radius, corners: corners))
    }
}

private struct IBRoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
