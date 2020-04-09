//
//  ReactiveExt.swift
//  SwiftFrame
//
//  Created by 杨建祥 on 2020/4/7.
//

import UIKit
import RxSwift
import RxCocoa
import QMUIKit
import Toast_Swift

public extension Reactive where Base: UIView {
    
    var loading: Binder<Bool> {
        return Binder(self.base) { view, loading in
            view.isUserInteractionEnabled = !loading
            loading ? view.makeToastActivity(.center) : view.hideToastActivity()
        }
    }
    
    var setNeedsLayout: Binder<Void> {
        return Binder(self.base) { view, _ in
            view.setNeedsLayout()
        }
    }
    
    var borderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.qmui_borderColor = attr
        }
    }
    
}

