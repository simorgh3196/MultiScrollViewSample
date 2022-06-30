//
//  StackBaseViewController.swift
//  MultiScrollViewSample
//
//  Created by Tomoya Hayakawa on 2022/06/21.
//

import UIKit

/*
 ScrollViewで画像をまとめたStackViewを包み、StackViewの下に張り付くようにOffsetを監視してEndPageを動かしてみた。
 画像部分は拡大し、EndPageの拡大しない挙動は良い感じだが、これだとEndPage上のスクロールがScrollViewに伝播しない。
 惜しい。
 画像は一気に表示されるが、使用メモリ量は大きめ画像20枚をAsset読み込みで100MBちょいくらいで、全読み込みでも問題なさそうな気がしている。
 ネットワーク優先順位問題があるので順次表示制御は必要にはなりそう。
 */

@MainActor
final class StackBaseViewController: UIViewController, UIScrollViewDelegate, EndPageViewDelegate {
  private let imageItemViewControllers = (1..<20).shuffled().prefix(20).map {
    ImageItemViewController(imageName: "Image\($0)", imageSize: CGSize(width: 750, height: 1899))
  }
  private let endPageViewController = EndPageViewController()

  private var scrollView: UIScrollView!
  private var endPageViewOffsetConstraint: NSLayoutConstraint!
  private var observation: NSKeyValueObservation!

  private lazy var contentView = UIStackView.vertical {
    imageItemViewControllers.map(\.view)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    endPageViewController.delegate = self

    // Setup scroll view
    scrollView = UIScrollView()
    scrollView.backgroundColor = .lightGray
    scrollView.minimumZoomScale = 1.0
    scrollView.maximumZoomScale = 3.0
    scrollView.contentInset.bottom = endPageViewController.view.frame.height
    scrollView.delegate = self
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    scrollView.frameLayoutGuide.pinEdges(to: view)

    observation = scrollView.observe(\.contentOffset, options: [.initial, .new]) { scrollView, change in
      Task {
        await MainActor.run {
          let contentOffset = change.newValue!
          let bottomPositionY = contentOffset.y + scrollView.frame.size.height
          let contentHeight = scrollView.contentSize.height

          // Update EndPage offset
          self.endPageViewOffsetConstraint.constant = contentHeight - contentOffset.y

          // Handle Showing EndPage
          let reachedBottomOfContent = contentHeight < bottomPositionY
          if reachedBottomOfContent { /* do something */}

          self.imageItemViewControllers.forEach { viewController in
            let frame = viewController.view.convert(viewController.view.bounds, to: scrollView)
            let padding = scrollView.frame.height / 2

            let shouldHideImage = frame.maxY < (contentOffset.y - padding) || (bottomPositionY + padding) < frame.minY
            viewController.isImageHidden(shouldHideImage)
          }
        }
      }
    }

    // Setup content view
    scrollView.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.pinEdges(to: scrollView.contentLayoutGuide)
    contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true

    // Add endPageViewController as footer
    view.addSubview(endPageViewController.view)
    endPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
    endPageViewOffsetConstraint = endPageViewController.view.topAnchor
      .constraint(equalTo: view.topAnchor, constant: view.frame.height) // First time, hide under view
    NSLayoutConstraint.activate([
      endPageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      endPageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      endPageViewOffsetConstraint,
    ])

    // Append to child view controller
    (imageItemViewControllers + [endPageViewController]).forEach { viewController in
      addChild(viewController)
      viewController.didMove(toParent: self)
    }
  }

  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    contentView
  }

  func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    guard view === contentView else { return }
    print("scrollView\n contentInset: \(scrollView.contentInset)\n adjustedContentInset: \(scrollView.adjustedContentInset)\n safeAreaInsets: \(scrollView.safeAreaInsets)")
  }

  func endPageViewController(_: EndPageViewController, didChangeContentHeight contentHeight: CGFloat) {
    print("EndPage.height: \(contentHeight)")
    scrollView.contentInset.bottom = contentHeight
  }
}

/// 画像1枚を画面全体に表示するViewController。
/// 画面サイズは画像の縦横比で決定される。
@MainActor
fileprivate final class ImageItemViewController: UIViewController {
  private let imageView = UIImageView()

  private let imageName: String
  private let imageSize: CGSize

  init(imageName: String, imageSize: CGSize) {
    self.imageName = imageName
    self.imageSize = imageSize
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func isImageHidden(_ isHidden: Bool) {
    if isHidden {
      imageView.image = nil
    } else if imageView.image == nil {
      imageView.image = UIImage(named: imageName)!
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let imageRatio = imageSize.width / imageSize.height
    view.addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.pinEdgesToSuperview()
    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageRatio).isActive = true
  }
}
