//
//  AutoLayoutHelper.swift
//  MultiScrollViewSample
//
//  Created by Tomoya Hayakawa on 2022/06/21.
//

import UIKit

extension UIView {
  func pinCenter(to view: UIView) {
    assert(translatesAutoresizingMaskIntoConstraints == false,
           "translatesAutoresizingMaskIntoConstraints must be false")
    NSLayoutConstraint.activate([
      centerXAnchor.constraint(equalTo: view.centerXAnchor),
      centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }

  func pinCenter(to layoutGuide: UILayoutGuide) {
    assert(translatesAutoresizingMaskIntoConstraints == false,
           "translatesAutoresizingMaskIntoConstraints must be false")
    NSLayoutConstraint.activate([
      centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
      centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor),
    ])
  }

  func pinCenterToSuperview() {
    assert(superview != nil, "View must have superview")
    guard let superview = superview else { return }
    pinCenter(to: superview)
  }

  func pinEdges(to view: UIView, with insets: UIEdgeInsets = .zero) {
    assert(translatesAutoresizingMaskIntoConstraints == false,
           "translatesAutoresizingMaskIntoConstraints must be false")
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
      leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
      trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right),
      bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom)
    ])
  }

  func pinEdges(to layoutGuide: UILayoutGuide, with insets: UIEdgeInsets = .zero) {
    assert(translatesAutoresizingMaskIntoConstraints == false,
           "translatesAutoresizingMaskIntoConstraints must be false")
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: insets.top),
      leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: insets.left),
      trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: insets.right),
      bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: insets.bottom)
    ])
  }

  func pinEdgesToSuperview(with insets: UIEdgeInsets = .zero) {
    assert(superview != nil, "View must have superview")
    guard let superview = superview else { return }
    pinEdges(to: superview, with: insets)
  }
}

extension UILayoutGuide {
  func pinCenter(to view: UIView) {
    assert(owningView?.translatesAutoresizingMaskIntoConstraints == false,
           "translatesAutoresizingMaskIntoConstraints must be false")
    NSLayoutConstraint.activate([
      centerXAnchor.constraint(equalTo: view.centerXAnchor),
      centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }

  func pinCenter(to layoutGuide: UILayoutGuide) {
    assert(owningView?.translatesAutoresizingMaskIntoConstraints == false,
           "translatesAutoresizingMaskIntoConstraints must be false")
    NSLayoutConstraint.activate([
      centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
      centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor),
    ])
  }
  func pinEdges(to view: UIView, with insets: UIEdgeInsets = .zero) {
    assert(owningView?.translatesAutoresizingMaskIntoConstraints == false,
           "translatesAutoresizingMaskIntoConstraints must be false")
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
      leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
      trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right),
      bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom)
    ])
  }

  func pinEdges(to layoutGuide: UILayoutGuide, with insets: UIEdgeInsets = .zero) {
    assert(owningView?.translatesAutoresizingMaskIntoConstraints == false,
           "translatesAutoresizingMaskIntoConstraints must be false")
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: insets.top),
      leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: insets.left),
      trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: insets.right),
      bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: insets.bottom)
    ])
  }
}
