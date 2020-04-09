//
//  ObservableExt.swift
//  SwiftFrame
//
//  Created by 杨建祥 on 2020/4/9.
//

import UIKit
import RxSwift
import RxCocoa

// YJX_TODO 与RxOptional重复

public extension ObservableType {

    func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }

    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}

public extension ObservableType where Element == Bool {
    /// Boolean not operator
    public func not() -> Observable<Bool> {
        return self.map(!)
    }
}

public extension Observable where Element: BooleanType {
    func not() -> Observable<Bool> {
        return self.map { input in
            return !input.boolValue
        }
    }
}

public extension Observable where Element: Equatable {
    func ignore(value: Element) -> Observable<Element> {
        return filter { (selfE) -> Bool in
            return value != selfE
        }
    }
}
