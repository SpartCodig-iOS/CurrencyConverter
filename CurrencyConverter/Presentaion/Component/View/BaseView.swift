//
//  BaseView.swift
//  CurrencyConverter
//
//  Created by Wonji Suh  on 9/29/25.
//

import UIKit

open class BaseView: UIView {

  public override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 초기 UI 구성 훅
  open func configureUI() {
    addView()
    setAttributes()
  }

  /// 서브뷰 추가 훅
  open func addView() {
    defineLayout()
  }

  /// 속성 세팅 훅
  open func setAttributes() {}

  /// 오토레이아웃/플렉스 레이아웃 정의 훅
  open func defineLayout() {}
}

