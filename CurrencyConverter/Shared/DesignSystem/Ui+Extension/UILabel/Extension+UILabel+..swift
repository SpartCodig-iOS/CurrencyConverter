//
//  Extension+UILabel+..swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import UIKit
import Then

public extension UILabel {
  static func createLabel(
    text: String? = nil,
    family: PretendardFontFamily,
    size: CGFloat,
    color: UIColor,
    alignment: NSTextAlignment = .left,
    lines: Int = 1,
    lineBreak: NSLineBreakMode = .byTruncatingTail
  ) -> UILabel {
    UILabel().then {
      $0.text = text
      $0.font = .pretendardFont(family: family, size: size)
      $0.textColor = color
      $0.textAlignment = alignment
      $0.numberOfLines = lines
      $0.lineBreakMode = lineBreak
    }
  }
}
