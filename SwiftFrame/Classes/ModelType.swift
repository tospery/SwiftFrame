//
//  ModelType.swift
//  SwiftFrame
//
//  Created by 杨建祥 on 2020/4/5.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper
import Cache

// MARK: - 私有变量
private var streams: [String: Any] = [:]
private var subjects: [String: Any] = [:]
private var storage: Storage = try! Storage(diskConfig: DiskConfig(name: "shared"), memoryConfig: MemoryConfig(), transformer: TransformerFactory.forCodable(ofType: String.self))

// MARK: - 标识协议
public protocol Identifiable {
    var id: String? { get }
}

// MARK: - 模型协议
public protocol ModelType: Identifiable, Mappable {
    init()
}

// MARK: - 事件协议
public protocol Eventable {
    associatedtype Event
    static var event: PublishSubject<Event> { get }
}

public extension Eventable {
    static var event: PublishSubject<Event> {
        let key = String(describing: self)
        if let stream = streams[key] as? PublishSubject<Event> {
            return stream
        }
        let stream = PublishSubject<Event>()
        streams[key] = stream
        return stream
    }
}

// MARK: - 存储协议
public protocol Storable: Codable, Equatable, Identifiable, Mappable {
    func save()
    
    static func objectStoreKey(id: String?) -> String
    static func arrayStoreKey() -> String

    static func storeObject(_ object: Self, id: String?)

    static func cachedObject(id: String?) -> Self?
    static func cachedArray() -> Array<Self>?

    static func eraseObject(id: String?)
}

public extension Storable {

    func save() {
        type(of: self).storeObject(self, id: self.id)
    }

    static func arrayStoreKey() -> String {
        return String(describing: self) + "#array"
    }

    static func objectStoreKey(id: String? = nil) -> String {
        guard let id = id else { return String(describing: self) + "#object" }
        return String(describing: self) + "#object#" + id
    }

    static func storeObject(_ object: Self, id: String? = nil) {
        let key = self.objectStoreKey(id: id)
        try? storage.transformCodable(ofType: self).setObject(object, forKey: key)
    }

    static func cachedObject(id: String? = nil) -> Self? {
        let key = self.objectStoreKey(id: id)
        if let object = try? storage.transformCodable(ofType: self).object(forKey: key) {
            return object
        }

        if let path = Bundle.main.path(forResource: key, ofType: "json"),
            let json = try? String(contentsOfFile: path, encoding: .utf8) {
            return Self(JSONString: json)
        }

        return nil
    }

    static func cachedArray() -> Array<Self>? {
        let key = self.arrayStoreKey()
        if let array = try? storage.transformCodable(ofType: Array<Self>.self).object(forKey: key) {
            return array
        }

        if let path = Bundle.main.path(forResource: key, ofType: "json"),
            let json = try? String(contentsOfFile: path, encoding: .utf8) {
            return Array<Self>(JSONString: json)
        }

        return nil
    }

    static func eraseObject(id: String? = nil) {
        let key = self.objectStoreKey(id: id)
        try? storage.removeObject(forKey: key)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - 流协议
public protocol Subjective: Storable {
    static func subject() -> BehaviorRelay<Self?>
    static func current() -> Self?
    static func update(value: Self?)
}

public extension Subjective {
    static func subject() -> BehaviorRelay<Self?> {
        let key = String(describing: self)
        if let subject = subjects[key] as? BehaviorRelay<Self?> {
            return subject
        }
        let subject = BehaviorRelay<Self?>(value: Self.cachedObject())
        subjects[key] = subject
        return subject
    }
    
    static func current() -> Self? {
        self.subject().value
    }

    static func update(value: Self?) {
        let subject = self.subject()
        guard let value = value else {
            Self.eraseObject()
            subject.accept(nil)
            return
        }
        
        Self.storeObject(value)
        subject.accept(value)
    }

}

