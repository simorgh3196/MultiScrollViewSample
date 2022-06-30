//
//  UIStackViewBuilder.swift
//  MultiScrollViewSample
//
//  Created by Tomoya Hayakawa on 2022/06/22.
//

import UIKit

func customSpacingForPreviousView(_ spacing: CGFloat) -> UIView { UIView() }

@resultBuilder
public struct StackViewBuilder {
    enum Content {
        case view(UIView)
        case optionalView(UIView)
        case eatherView(UIView)
        case customSpace(CGFloat)
    }

    typealias Expression = UIView
    typealias Component = [UIView]

    static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }

    static func buildExpression(_ expression: [Expression]) -> Component {
        expression
    }

    static func buildBlock(_ components: Component...) -> Component {
        components.flatMap { $0 }
    }

    static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }

    static func buildArray(_ components: [Component]) -> Component {
        components.flatMap { $0 }
    }

    static func buildEither(first component: Component) -> Component {
        component
    }
}

extension UIStackView {
    /// Creates an instance of `UIStackView` with a vertical axis by using builder.
    ///
    /// - parameter disribution: The layout of the arrangedSubviews along the axis. (default: .fill)
    /// - parameter alighment: The layout of the arrangedSubviews transverse to the axis. (default: .fill)
    /// - parameter spacing: Spacing between adjacent edges of arrangedSubviews. (default: .zero)
    /// - parameter content: A view builder that creates the content of this stack.
    public static func vertical(distribution: UIStackView.Distribution = .fill,
                                alignment: UIStackView.Alignment = .fill,
                                spacing: CGFloat = .zero,
                                @StackViewBuilder _ content: () -> [UIView] = { [] }) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: content())
        stackView.axis = .vertical
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.spacing = spacing
        return stackView
    }

    /// Creates an instance of `UIStackView` with a horizontal axis by using builder.
    ///
    /// - parameter disribution: The layout of the arrangedSubviews along the axis. (default: .fill)
    /// - parameter alighment: The layout of the arrangedSubviews transverse to the axis. (default: .fill)
    /// - parameter spacing: Spacing between adjacent edges of arrangedSubviews. (default: .zero)
    /// - parameter content: A view builder that creates the content of this stack.
    public static func horizontal(distribution: UIStackView.Distribution = .fill,
                                  alignment: UIStackView.Alignment = .fill,
                                  spacing: CGFloat = .zero,
                                  @StackViewBuilder _ content: () -> [UIView] = { [] }) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: content())
        stackView.axis = .horizontal
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.spacing = spacing
        return stackView
    }

    /// Reset the arrangedSubviews list.
    ///
    /// - parameter content: A view builder that creates the content of this stack.
    public func setArrangedSubviews(@StackViewBuilder _ content: () -> [UIView]) {
        // Remove all subviews.
        let previousSubviews = subviews
        previousSubviews.forEach { subview in
            subview.removeFromSuperview()
        }

        // Add new views.
        let newSubviews = content()
        newSubviews.forEach(addArrangedSubview)
    }

    /// Add the arrangedSubviews list.
    ///
    /// - parameter content: A view builder that creates the content of this stack.
    public func addArrangedSubviews(@StackViewBuilder _ content: () -> [UIView]) {
        // Add new views.
        let newSubviews = content()
        newSubviews.forEach(addArrangedSubview)
    }
}
