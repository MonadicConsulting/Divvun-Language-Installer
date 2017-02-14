//
//  Optional+FP.swift
//  FPExamples
//
//  Created by Charlotte Tortorella on 20/09/2016.
//  Copyright © 2016 Charlotte Tortorella. All rights reserved.
//

extension Optional where Wrapped: Equatable {
    /// If `self == value`, returns `self`. Otherwise, returns `nil`.
    
    func filter(matching value: Wrapped) -> Wrapped? {
        guard self == value else { return nil }
        return self
    }
    
    /// If `self != value`, returns `self`. Otherwise, returns `nil`.
    
    func ignore(matching value: Wrapped) -> Wrapped? {
        guard self != value else { return nil }
        return self
    }
    
    /// If `self != value`, returns `nil`. Otherwise, returns `value`.
    
    func filterMap<T>(matching value: Wrapped, with replacement: @autoclosure () throws -> T?) rethrows -> T? {
        guard self == value else { return nil }
        return try replacement()
    }
}

extension Optional {
    
    /// Equivalent to `self ?? defaultValue`.
    /// Use to improve clarity at the end of a map/filter chain.

    func unwrap(default defaultValue: @autoclosure () throws -> Wrapped) rethrows -> Wrapped {
        switch self {
        case .some(let value):
            return value
        case .none:
            return try defaultValue()
        }
    }
    
    /// Equivalent to `self ?? defaultValue`.
    /// Use to improve clarity at the end of a map/filter chain.
    
    func unwrap(default defaultValue: @autoclosure () throws -> Wrapped?) rethrows -> Wrapped? {
        switch self {
        case .some(let value):
            return value
        case .none:
            return try defaultValue()
        }
    }
    
    /// If `self != nil`, `f(self!)` is called.
    
    func sideEffect<T>(_ f: (Wrapped) -> T) {
        if let value = self {
            _ = f(value)
        }
    }
    
    /// If `first == nil || second == nil`, returns nil. Otherwise
    /// returns `f(self!, second!)`
    
    static func map<U, V>(_ first: U?, _ second: V?, _ f: (U, V) throws -> Wrapped) rethrows -> Wrapped? {
        return try flatMap(first, second, f)
    }
    
    /// If `first == nil || second == nil || third == nil`, returns
    /// nil. Otherwise returns `f(self!, second!, third!)`
    
    static func map<U, V, W>(_ first: U?, _ second: V?, _ third: W?, _ f: (U, V, W) throws -> Wrapped) rethrows -> Wrapped? {
        return try flatMap(first, second, third, f)
    }
    
    /// If `first == nil || second == nil || third == nil ||
    /// fourth == nil`, returns nil. Otherwise returns
    /// `f(self!, second!, third!, fourth!)`
    
    static func map<U, V, W, X>(_ first: U?, _ second: V?, _ third: W?, _ fourth: X?, _ f: (U, V, W, X) throws -> Wrapped) rethrows -> Wrapped? {
        return try flatMap(first, second, third, fourth, f)
    }
    
    /// If `first == nil || second == nil || third == nil ||
    /// fourth == nil || fifth == nil`, returns `nil`.
    // Otherwise returns `f(self!, second!, third!, fourth!, fifth!)`
    
    static func map<U, V, W, X, Y>(_ first: U?, _ second: V?, _ third: W?, _ fourth: X?, _ fifth: Y?, _ f: (U, V, W, X, Y) throws -> Wrapped) rethrows -> Wrapped? {
        return try flatMap(first, second, third, fourth, fifth, f)
    }
    
    /// If `first == nil || second == nil`, returns nil. Otherwise
    /// returns `f(self!, second!)`
    
    static func flatMap<U, V>(_ first: U?, _ second: V?, _ f: (U, V) throws -> Wrapped?) rethrows -> Wrapped? {
        guard let first = first, let second = second else { return nil }
        return try f(first, second)
    }
    
    /// If `first == nil || second == nil || third == nil`, returns
    /// nil. Otherwise returns `f(self!, second!, third!)`
    
    static func flatMap<U, V, W>(_ first: U?, _ second: V?, _ third: W?, _ f: (U, V, W) throws -> Wrapped?) rethrows -> Wrapped? {
        guard let first = first, let second = second, let third = third else { return nil }
        return try f(first, second, third)
    }
    
    /// If `first == nil || second == nil || third == nil ||
    /// fourth == nil`, returns nil. Otherwise returns
    /// `f(self!, second!, third!, fourth!)`
    
    static func flatMap<U, V, W, X>(_ first: U?, _ second: V?, _ third: W?, _ fourth: X?, _ f: (U, V, W, X) throws -> Wrapped?) rethrows -> Wrapped? {
        guard let first = first, let second = second, let third = third, let fourth = fourth else { return nil }
        return try f(first, second, third, fourth)
    }
    
    /// If `first == nil || second == nil || third == nil ||
    /// fourth == nil || fifth == nil`, returns `nil`.
    /// Otherwise returns `f(self!, second!, third!, fourth!, fifth!)`
    
    static func flatMap<U, V, W, X, Y>(_ first: U?, _ second: V?, _ third: W?, _ fourth: X?, _ fifth: Y?, _ f: (U, V, W, X, Y) throws -> Wrapped?) rethrows -> Wrapped? {
        guard let first = first, let second = second, let third = third, let fourth = fourth, let fifth = fifth else { return nil }
        return try f(first, second, third, fourth, fifth)
    }
    
    /// If `self` statisfies `predicate`, returns `Optional(self)`. Otherwise, returns `nil`.
    
    func filter(includeValue predicate: (Wrapped) throws -> Bool) rethrows -> Wrapped? {
        guard let value = self, try predicate(value) else { return nil }
        return value
    }
    
    /// If `self == nil`, returns `nil`. Otherwise, returns `value`.
    
    func replace<T>(with replacement: @autoclosure () throws -> T?) rethrows -> T? {
        guard self != nil else { return nil }
        return try replacement()
    }
    
    /// If `function == nil || value == nil`, returns `nil`.
    /// Otherwise, returns `function!(value!)`
    
    static func apply<A>(_ f: ((A) -> Wrapped)?, _ value: A?) -> Wrapped? {
        guard let f = f, let value = value else { return nil }
        return f(value)
    }
    
    /// If `f == nil || self == nil`, returns `nil`.
    /// Otherwise, returns `function!(self!)`
    
    func apply<A>(_ f: ((Wrapped) -> A)?) -> A? {
        guard let f = f, let value = self else { return nil }
        return f(value)
    }
}

