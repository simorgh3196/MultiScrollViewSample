//
//  CollectionBaseViewController.swift
//  MultiScrollViewSample
//
//  Created by Tomoya Hayakawa on 2022/06/24.
//

import UIKit

@MainActor
final class CollectionBaseViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, EndPageViewDelegate {
  private var collectionView: UICollectionView!
  private let imageItems = (1..<20).shuffled().prefix(5).map { UIImage(named: "Image\($0)")! }
  private let endPageViewController = EndPageViewController()

  private var endPageViewHeight: CGFloat = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    let scrollView = UIScrollView()
    scrollView.backgroundColor = .lightGray
    scrollView.minimumZoomScale = 1.0
    scrollView.maximumZoomScale = 3.0
    scrollView.delegate = self
    view.addSubview(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.frameLayoutGuide.pinEdges(to: view)

    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
    collectionView.backgroundColor = .lightGray
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
    collectionView.register(ViewControllerContainerCell.self, forCellWithReuseIdentifier: "VCContainerCell")
    scrollView.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false

    addChild(endPageViewController)
    endPageViewController.didMove(toParent: self)
    endPageViewController.delegate = self
//    scrollView.addSubview(endPageViewController.view)
    endPageViewController.view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      collectionView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
      collectionView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
      collectionView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

//      endPageViewController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
//      endPageViewController.view.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
//      endPageViewController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
//      endPageViewController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
//      endPageViewController.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
    ])
  }

  func numberOfSections(in _: UICollectionView) -> Int { 1 }

  func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 { return imageItems.count }
    if section == 1 { return 1 }
    return 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch indexPath.section {
    case 0:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
      cell.configure(image: imageItems[indexPath.item])
      return cell
    case 1:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VCContainerCell", for: indexPath) as! ViewControllerContainerCell
      cell.configure(viewController: endPageViewController)
      return cell
    default:
      fatalError("Invalid indexPath")
    }
  }

  func collectionView(_: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch indexPath.section {
    case 0:
      let image = imageItems[indexPath.item]
      let imageRatio = image.size.width / image.size.height
      return CGSize(width: view.frame.width, height: view.frame.width / imageRatio)
    case 1:
      let maxSize = CGSize(width: view.frame.width, height: CGFloat.greatestFiniteMagnitude)
      endPageViewController.loadViewIfNeeded()
      let fitSize = endPageViewController.sizeThatFits(maxSize)
      let size = CGSize(width: view.frame.width, height: max(fitSize.height, 1))
      print(size)
      return size
    default:
      fatalError("Invalid indexPath")
    }
  }

//  func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
//    UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 400)
//  }

  func endPageViewController(_ viewController: EndPageViewController, didChangeContentHeight: CGFloat) {
//    collectionView.reloadData()
  }

  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    guard scrollView as? UICollectionView == nil else { return nil }
    return collectionView
  }
}

final class ImageCell: UICollectionViewCell {
  private let imageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }

  func configure(image: UIImage) {
    imageView.image = image
  }

  private func setupUI() {
    contentView.addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.pinEdgesToSuperview()
  }
}

final class ViewControllerContainerCell: UICollectionViewCell {
  private weak var viewController: UIViewController?

  override func prepareForReuse() {
    super.prepareForReuse()
    contentView.subviews.forEach {
      $0.removeFromSuperview()
    }
  }

  func configure(viewController: UIViewController) {
    self.viewController = viewController
    contentView.addSubview(viewController.view)
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    viewController.view.pinEdgesToSuperview()
  }
}
