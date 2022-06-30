//
//  EndPageViewController.swift
//  MultiScrollViewSample
//
//  Created by Tomoya Hayakawa on 2022/06/24.
//

import UIKit

@MainActor
protocol EndPageViewDelegate: AnyObject {
  func endPageViewController(_ viewController: EndPageViewController, didChangeContentHeight contentHeight: CGFloat)
}

/// 画像の一覧の最後に表示するページを表すViewController
/// 動的に内部の要素が変化し、ViewControllerの高さも変動する
@MainActor
final class EndPageViewController: UIViewController {
  private var contentView: UIView!
  private let itemContainerView = UIStackView.vertical(spacing: 8)

  weak var delegate: EndPageViewDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .black

    let contentView = UIStackView.vertical(alignment: .fill, spacing: 16) {
      UIStackView.horizontal(distribution: .fillEqually, alignment: .center, spacing: 24) {
        UIButton.systemButton(with: UIImage(systemName: "plus.circle.fill")!,
                              target: self,
                              action: #selector(didTapAddButton(_:)))
        UIButton.systemButton(with: UIImage(systemName: "minus.circle.fill")!,
                              target: self,
                              action: #selector(didTapRemoveButton(_:)))
      }

      itemContainerView
    }

    view.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.pinCenterToSuperview()
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 16),
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
      contentView.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: -16),
    ])
    self.contentView = contentView
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    let newHeight = sizeThatFits(CGSize(width: view.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
    delegate?.endPageViewController(self, didChangeContentHeight: newHeight)
    print("EndPage viewDidLayoutSubviews() | \(newHeight)")
  }

  func sizeThatFits(_ size: CGSize) -> CGSize {
    let fitSize = contentView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
    let horizontalMargin: CGFloat = 24
    let verticalMargin: CGFloat = 16

    return CGSize(width: fitSize.width + horizontalMargin * 2,
                  height: fitSize.height + verticalMargin * 2)
  }

  @objc private func didTapAddButton(_: UIButton) { addNewItem() }
  @objc private func didTapRemoveButton(_: UIButton) { removeFirstItem() }

  private func addNewItem() {
    itemContainerView.addArrangedSubview(makeNewItem())

    let newHeight = sizeThatFits(CGSize(width: view.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
    delegate?.endPageViewController(self, didChangeContentHeight: newHeight)
  }

  private func removeFirstItem() {
    if let firstItem = itemContainerView.arrangedSubviews.first {
      firstItem.removeFromSuperview()

      let newHeight = sizeThatFits(CGSize(width: view.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
      delegate?.endPageViewController(self, didChangeContentHeight: newHeight)
    }
  }

  private func makeNewItem() -> UIView {
    let itemView = UIView()
    itemView.backgroundColor = .white
    itemView.layer.cornerRadius = 12
    itemView.layer.borderColor = UIColor.lightGray.cgColor
    itemView.layer.borderWidth = 0.5
    itemView.layer.shadowRadius = 2
    itemView.layer.shadowOpacity = 0.1
    itemView.translatesAutoresizingMaskIntoConstraints = false
    itemView.heightAnchor.constraint(equalToConstant: 150).isActive = true

    let label = UILabel()
    label.textColor = .darkGray
    label.text = String(Date().timeIntervalSince1970)
    label.translatesAutoresizingMaskIntoConstraints = false

    itemView.addSubview(label)
    label.pinCenter(to: itemView)

    return itemView
  }
}
