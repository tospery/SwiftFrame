//
//  BaseCellReactor.swift
//  SwiftFrame
//
//  Created by 杨建祥 on 2020/4/5.
//

import UIKit

open class BaseCellReactor: ReactorType {

    let model: ModelType
    // weak var cell : BaseCollectionCell?
    
    required public init(_ model: ModelType) {
        self.model = model
    }
    
}
