//
//  MultiScrollViewController.swift
//  MultiScrollViewSample
//
//  Created by Tomoya Hayakawa on 2022/06/29.
//

import UIKit

@MainActor
final class MultiScrollViewController: UIViewController {
  var minimumZoomScale: CGFloat = 1.0
  var maximumZoomScale: CGFloat = 3.0
  var zoomScaleWhenDoubleTapped: CGFloat = 2.0

  private let imageItemViews = (1..<20).shuffled().prefix(10).map {
    let imageRatio = 750.0 / 1899.0
    let imageView = UIImageView(image: UIImage(named: "Image\($0)")!)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageRatio).isActive = true
    return imageView
  }
  private let endPageViewController = EndPageViewController()

  private let contentView = UIStackView.vertical()
  private let verticalScrollView = UIScrollView()
  private let horizontalScrollView = UIScrollView()
  private var contentWidthConstraint: NSLayoutConstraint!

  private var isContentZooming: Bool { contentWidthConstraint.multiplier != 1 }

  override func viewDidLoad() {
    super.viewDidLoad()

    verticalScrollView.backgroundColor = .darkGray
    view.addSubview(verticalScrollView)
    verticalScrollView.translatesAutoresizingMaskIntoConstraints = false
    verticalScrollView.frameLayoutGuide.pinEdges(to: view)

    let containerView = UIStackView.vertical()
    verticalScrollView.addSubview(containerView)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.pinEdges(to: verticalScrollView.contentLayoutGuide)
    containerView.widthAnchor.constraint(equalTo: verticalScrollView.frameLayoutGuide.widthAnchor).isActive = true

    horizontalScrollView.backgroundColor = .lightGray
    horizontalScrollView.showsHorizontalScrollIndicator = false
    containerView.addArrangedSubview(horizontalScrollView)
    horizontalScrollView.translatesAutoresizingMaskIntoConstraints = false
    horizontalScrollView.frameLayoutGuide.heightAnchor.constraint(
      equalTo: horizontalScrollView.contentLayoutGuide.heightAnchor
    ).isActive = true

    contentView.setArrangedSubviews { imageItemViews }
    horizontalScrollView.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.pinEdges(to: horizontalScrollView.contentLayoutGuide)
    contentWidthConstraint = contentView.widthAnchor.constraint(
      equalTo: horizontalScrollView.frameLayoutGuide.widthAnchor
    )
    contentWidthConstraint.isActive = true

    containerView.addArrangedSubview(endPageViewController.view)
    addChild(endPageViewController)
    endPageViewController.didMove(toParent: self)

    let pinchGestureRecognizer = UIPinchGestureRecognizer()
    pinchGestureRecognizer.addTarget(self, action: #selector(didPinchContentView(_:)))
    horizontalScrollView.addGestureRecognizer(pinchGestureRecognizer)

    let doubleTapGestureRecognizer = UITapGestureRecognizer()
    doubleTapGestureRecognizer.numberOfTapsRequired = 2
    doubleTapGestureRecognizer.addTarget(self, action: #selector(didDoubleTapContentView(_:)))
    horizontalScrollView.addGestureRecognizer(doubleTapGestureRecognizer)
  }

  @objc
  private func didPinchContentView(_ gestureRecognizer: UIPinchGestureRecognizer) {
    if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
      let previousScale = contentWidthConstraint.multiplier
      let scale = previousScale * gestureRecognizer.scale
      zoomContent(to: scale, duration: 0.0, with: gestureRecognizer)
    }

    // Reset scale to avoid duplicate scaling.
    // More info: https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/handling_uikit_gestures/handling_pinch_gestures
    gestureRecognizer.scale = 1.0
  }

  @objc
  private func didDoubleTapContentView(_ gestureRecognizer: UIGestureRecognizer) {
    let scale = isContentZooming ? 1.0 : zoomScaleWhenDoubleTapped
    zoomContent(to: scale, duration: 0.2, with: gestureRecognizer)
  }

  private func zoomContent(to scale: CGFloat, duration: TimeInterval, with gestureRecognizer: UIGestureRecognizer) {
    let centerPointOfScrollView = gestureRecognizer.location(in: horizontalScrollView)
    let centerPointOfScreen = gestureRecognizer.location(in: view)

    let previousMultiplier = contentWidthConstraint.multiplier
    let actualMultiplier = max(minimumZoomScale, min(maximumZoomScale, scale))

    // Skip if no change in scale.
    guard previousMultiplier != actualMultiplier else { return }

    // Change zoom scale.
    contentWidthConstraint.isActive = false
    contentWidthConstraint = contentView.widthAnchor.constraint(
      equalTo: horizontalScrollView.frameLayoutGuide.widthAnchor,
      multiplier: actualMultiplier
    )
    contentWidthConstraint.isActive = true

    UIView.animate(withDuration: duration, animations: {
      self.verticalScrollView.layoutIfNeeded()

      let actualScale = actualMultiplier / previousMultiplier
      let minimumPosition = CGPoint(x: -self.horizontalScrollView.safeAreaInsets.left,
                                    y: -self.verticalScrollView.safeAreaInsets.top)
      let maximumPosition = CGPoint(x: self.horizontalScrollView.contentSize.width + self.horizontalScrollView.safeAreaInsets.right,
                                    y: self.verticalScrollView.contentSize.height + self.verticalScrollView.safeAreaInsets.bottom)
      let minimumOffset = minimumPosition
      let maximumOffset = CGPoint(x: maximumPosition.x - self.verticalScrollView.frame.width,
                                  y: maximumPosition.y - self.verticalScrollView.frame.height)

      // Change the Offset of ScrollView to fix the display position of the center point.
      let idealOffset = CGPoint(x: centerPointOfScrollView.x * actualScale - centerPointOfScreen.x,
                                y: centerPointOfScrollView.y * actualScale - centerPointOfScreen.y)

      let verticalScrollViewOffset = CGPoint(x: .zero,
                                             y: max(minimumOffset.y, min(maximumOffset.y, idealOffset.y)))
      let horizontalScrollViewOffset = CGPoint(x: max(minimumOffset.x, min(maximumOffset.x, idealOffset.x)),
                                               y: .zero)

      self.verticalScrollView.contentOffset = verticalScrollViewOffset
      self.horizontalScrollView.contentOffset = horizontalScrollViewOffset
    })
  }
}
