//
//  Extension+UILabel+..swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import UIKit

public extension UILabel {
  static func createLabel(
    for text: String,
    family: PretendardFontFamily,
    size: CGFloat,
    color: UIColor
  ) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = UIFont.pretendardFont(family: .bold, size: size)
    label.textColor = color
    label.textAlignment = .center
    label.numberOfLines = 0  // 필요한 만큼 줄 수 허용
    label.lineBreakMode = .byWordWrapping  // 단어 단위로 줄바꿈
    return label
  }
}
