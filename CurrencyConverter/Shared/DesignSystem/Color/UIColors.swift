//
//  UIColors.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import UIKit

public extension UIColor {

  // MARK: - Static Basic

  static var staticWhite: UIColor { UIColor(hex: "FFFFFF") }
  static var staticBlack: UIColor { UIColor(hex: "0C0E0F") }

  // MARK: - Static Text
  static var textPrimary: UIColor { UIColor(hex: "FFFFFF") }
  static var textSecondary: UIColor { UIColor(hex: "EAEAEA") }
  static var textSecondary100: UIColor { UIColor(hex: "525252") }
  static var textInactive: UIColor { UIColor(hex: "70737C").withAlphaComponent(0.28) }

  // MARK: - Static Background
  static var backGroundPrimary: UIColor { UIColor(hex: "0C0E0F") }
  static var backgroundInverse: UIColor { UIColor(hex: "FFFFFF") }

  // MARK: - Static Border
  static var borderInactive: UIColor { UIColor(hex: "C6C6C6") }
  static var borderDisabled: UIColor { UIColor(hex: "323537") }
  static var borderInverse: UIColor { UIColor(hex: "202325") }

  // MARK: - Static Status

  static var statusFocus: UIColor { UIColor(hex: "0D82F9") }
  static var statusCautionary: UIColor { UIColor(hex: "FD5D08") }
  static var statusError: UIColor { UIColor(hex: "FD1008") }

  // MARK: - Primitives

  static var grayBlack: UIColor { UIColor(hex: "1A1A1A") }
  static var gray80: UIColor { UIColor(hex: "323537") }
  static var gray60: UIColor { UIColor(hex: "6F6F6F") }
  static var gray40: UIColor { UIColor(hex: "A8A8A8") }
  static var gray90: UIColor { UIColor(hex: "202325") }
  static var grayError: UIColor { UIColor(hex: "FF5050") }
  static var grayWhite: UIColor { UIColor(hex: "FFFFFF") }
  static var grayPrimary: UIColor { UIColor(hex: "0099FF") }

  // MARK: - Surface

  static var surfaceBackground: UIColor { UIColor(hex: "1A1A1A") }
  static var surfaceElevated: UIColor { UIColor(hex: "4D4D4D").withAlphaComponent(0.4) }
  static var surfaceNormal: UIColor { UIColor(hex: "FFFFFF") }
  static var surfaceAccent: UIColor { UIColor(hex: "E6E6E6") }
  static var surfaceDisable: UIColor { UIColor(hex: "808080") }
  static var surfaceEnable: UIColor { UIColor(hex: "0099FF") }
  static var surfaceError: UIColor { UIColor(hex: "FF5050").withAlphaComponent(0.2) }

  // MARK: - TextIcon

  static var onBackground: UIColor { UIColor(hex: "FFFFFF") }
  static var onNormal: UIColor { UIColor(hex: "1A1A1A") }
  static var onDisabled: UIColor { UIColor(hex: "4D4D4D").withAlphaComponent(0.4) }
  static var onError: UIColor { UIColor(hex: "FF5050") }

  // MARK: - NatureBlue

  static var blue10: UIColor { UIColor(hex: "F5F8FF") }
  static var blue20: UIColor { UIColor(hex: "E1EAFF") }
  static var blue30: UIColor { UIColor(hex: "C1D3FF") }
  static var blue40: UIColor { UIColor(hex: "0D82F9") }
  static var blue50: UIColor { UIColor(hex: "0c75e0") }
  static var blue60: UIColor { UIColor(hex: "0a68c7") }
  static var blue70: UIColor { UIColor(hex: "0a62bb") }
  static var blue80: UIColor { UIColor(hex: "084E95") }
  static var blue90: UIColor { UIColor(hex: "063A70") }
  static var blue100: UIColor { UIColor(hex: "052E57") }

  // MARK: - NatureRed
  static var red10: UIColor { UIColor(hex: "ffe7e6") }
  static var red20: UIColor { UIColor(hex: "ffdbda") }
  static var red30: UIColor { UIColor(hex: "feb5b2") }
  static var red40: UIColor { UIColor(hex: "fd1008") }
  static var red50: UIColor { UIColor(hex: "e40e07") }
  static var red60: UIColor { UIColor(hex: "ca0d06") }
  static var red70: UIColor { UIColor(hex: "be0c06") }
  static var red80: UIColor { UIColor(hex: "980a05") }
  static var red90: UIColor { UIColor(hex: "720704") }
  static var red100: UIColor { UIColor(hex: "590603") }

  static var basicBlack: UIColor { UIColor(hex: "1A1A1A") }
  static var gray200: UIColor { UIColor(hex: "E6E6E6") }
  static var gray300: UIColor { UIColor(hex: "8F8F8F") }
  static var gray400: UIColor { UIColor(hex: "B3B3B3") }
  static var gray600: UIColor { UIColor(hex: "808080") }
  static var gray800: UIColor { UIColor(hex: "4D4D4D") }

  static var error: UIColor { UIColor(hex: "FF5050") }
  static var basicBlue: UIColor { UIColor(hex: "0099FF") }

  static var basicBlackDimmed: UIColor { UIColor(hex: "333332").withAlphaComponent(0.7) }
}

