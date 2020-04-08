//
//  ScrollViewController.swift
//  SwiftFrame
//
//  Created by 杨建祥 on 2020/4/7.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator
import DZNEmptyDataSet

open class ScrollViewController: BaseViewController {
    
    public let emptyDataSetSubject = PublishSubject<Void>()
    public var loading = false
    public var error: Error?
    public var scrollView: UIScrollView!
    
    // MARK: - Init
    public override init(_ navigator: NavigatorType, _ reactor: BaseViewReactor) {
        super.init(navigator, reactor)
        var scrollView: UIScrollView!
        if self is TableViewController {
            scrollView = UITableView(frame: .zero)
        } else if self is CollectionViewController {
            scrollView = UICollectionView(frame: .zero, collectionViewLayout: (self as! CollectionViewController).layout)
        } else {
            scrollView = UIScrollView(frame: .zero)
        }
        scrollView.backgroundColor = .white
        scrollView.emptyDataSetSource = self
        scrollView.emptyDataSetDelegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        self.scrollView = scrollView
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.scrollView)
        self.scrollView.frame = self.contentFrame
    }
    
    // MARK: - Bind
    public override func bind(reactor: BaseViewReactor) {
        super.bind(reactor: reactor)
        // Bind
        self.scrollView.rx
            .setDelegate(self)
            .disposed(by: self.disposeBag)
    }
}

extension ScrollViewController: DZNEmptyDataSetSource {
    public func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return .white
    }
}

extension ScrollViewController: DZNEmptyDataSetDelegate {
    
    public func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return (self.loading == true || self.error != nil)
    }

    public func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
        return (self.loading == true || self.error == nil)
    }
    
    public func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        self.emptyDataSetSubject.onNext(())
    }
    
}

extension ScrollViewController: UIScrollViewDelegate {
    
}
