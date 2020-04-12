//
//  NSErrorExt.swift
//  SwiftFrame
//
//  Created by 杨建祥 on 2020/4/11.
//

import UIKit

public extension NSError {
    
    convenience init(code: Int, message: String?) {
        self.init(domain: UIApplication.shared.bundleIdentifier, code: code, userInfo: [NSLocalizedDescriptionKey: stringDefault(message, "未知错误")])
    }
    
    var isNetwork: Bool {
        return self.domain == NSURLErrorDomain
    }
    
    var isServer: Bool {
        return self.code == 500
    }
    
}
