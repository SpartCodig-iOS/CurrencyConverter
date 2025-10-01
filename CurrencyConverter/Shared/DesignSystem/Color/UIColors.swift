//
//  UIColors.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import UIKit

public extension UIColor {

  private static func appDynamic(lightHex: String, darkHex: String) -> UIColor {
    UIColor { trait in
      trait.userInterfaceStyle == .dark ? UIColor(hex: darkHex) : UIColor(hex: lightHex)
    }
  }

  static var appBackground: UIColor { appDynamic(lightHex: "FFFFFF", darkHex: "1C1C1E") }
  static var appPrimaryText: UIColor { appDynamic(lightHex: "000000", darkHex: "FFFFFF") }
  static var appSecondaryText: UIColor { appDynamic(lightHex: "666666", darkHex: "B3B3B3") }
  static var appCellBackground: UIColor { appDynamic(lightHex: "F2F2F2", darkHex: "333333") }
  static var appFavoriteActive: UIColor { appDynamic(lightHex: "FFFF00", darkHex: "FDFD96") }
  static var appFavoriteInactive: UIColor { appDynamic(lightHex: "C6C6C6", darkHex: "666666") }
  static var appButtonBackground: UIColor { appDynamic(lightHex: "0000FF", darkHex: "87CEEB") }
  static var appButtonTitle: UIColor { appDynamic(lightHex: "FFFFFF", darkHex: "1C1C1E") }
  static var appBorder: UIColor { appDynamic(lightHex: "C6C6C6", darkHex: "4D4D4D") }
  static var appTrendUp: UIColor { appDynamic(lightHex: "34C759", darkHex: "30D158") }
  static var appTrendDown: UIColor { appDynamic(lightHex: "FF3B30", darkHex: "FF453A") }
}
