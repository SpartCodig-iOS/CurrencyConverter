//
//  Extension+UIColor.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import Foundation

import UIKit

public extension UIColor {
  convenience init(hex: String, alpha: CGFloat = 1.0) {
    let scanner = Scanner(string: hex)
    _ = scanner.scanString("#")

    var rgb: UInt64 = 0
    scanner.scanHexInt64(&rgb)

    let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
    let g = CGFloat((rgb >>  8) & 0xFF) / 255.0
    let b = CGFloat((rgb >>  0) & 0xFF) / 255.0
    self.init(red: r, green: g, blue: b, alpha: alpha)
  }
}
