//
//  PretendardFont.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation
import UIKit

public extension UIFont {
  static func pretendardFont(family: PretendardFontFamily, size: CGFloat) -> UIFont {
    let fontName = "PretendardVariable-\(family)"
    return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
  }

  struct Pretendard {
    static func title(size: CGFloat) -> UIFont {
      return UIFont.pretendardFont(family: .semiBold, size: size)
    }

    static func body(size: CGFloat) -> UIFont {
      return UIFont.pretendardFont(family: .regular, size: size)
    }

    static func caption(size: CGFloat) -> UIFont {
      return UIFont.pretendardFont(family: .medium, size: size)
    }

    static func amount(size: CGFloat) -> UIFont {
      return UIFont.pretendardFont(family: .bold, size: size)
    }

    static func button(size: CGFloat) -> UIFont {
      return UIFont.pretendardFont(family: .semiBold, size: size)
    }
  }
}

// MARK: - UILabel Extension
public extension UILabel {
  func setPretendardFont(family: PretendardFontFamily, size: CGFloat) {
    self.font = UIFont.pretendardFont(family: family, size: size)
  }
}

// MARK: - UITextField Extension
public extension UITextField {
  func setPretendardFont(family: PretendardFontFamily, size: CGFloat) {
    self.font = UIFont.pretendardFont(family: family, size: size)
  }
}

// MARK: - UITextView Extension
public extension UITextView {
  func setPretendardFont(family: PretendardFontFamily, size: CGFloat) {
    self.font = UIFont.pretendardFont(family: family, size: size)
  }
}

// MARK: - UIButton Extension
public extension UIButton {
  func setPretendardFont(family: PretendardFontFamily, size: CGFloat) {
    self.titleLabel?.font = UIFont.pretendardFont(family: family, size: size)
  }
}
