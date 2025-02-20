//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// Bridged C++ iterator that allows to traverse the elements of a sequence 
/// using a for-in loop.
///
/// Mostly useful for conforming a type to the `CxxSequence` protocol and should
/// not generally be used directly.
///
/// - SeeAlso: https://en.cppreference.com/w/cpp/named_req/InputIterator
public protocol UnsafeCxxInputIterator: Equatable {
  associatedtype Pointee: ~Copyable

  /// Returns the unwrapped result of C++ `operator*()`.
  ///
  /// Generally, Swift creates this property automatically for C++ types that
  /// define `operator*()`.
  @_borrowed
  var pointee: Pointee { get }

  /// Returns an iterator pointing to the next item in the sequence.
  ///
  /// Generally, Swift creates this property automatically for C++ types that
  /// define pre-increment `operator++()`.
  func successor() -> Self
}

extension UnsafePointer: UnsafeCxxInputIterator
where Pointee: ~Copyable {}

extension UnsafeMutablePointer: UnsafeCxxInputIterator
where Pointee: ~Copyable {}

extension Optional: UnsafeCxxInputIterator where Wrapped: UnsafeCxxInputIterator {
  public typealias Pointee = Wrapped.Pointee

  @inlinable
  public var pointee: Pointee {
    _read {
      guard let value = self else {
        fatalError("Could not dereference nullptr")
      }
      yield value.pointee
    }
  }

  @inlinable
  public func successor() -> Self {
    if let value = self {
      return value.successor()
    }
    fatalError("Could not increment nullptr")
  }
}

public protocol UnsafeCxxMutableInputIterator: UnsafeCxxInputIterator {
  @_borrowed
  override var pointee: Pointee { get set }
}

extension UnsafeMutablePointer: UnsafeCxxMutableInputIterator
where Pointee: ~Copyable {}

/// Bridged C++ iterator that allows computing the distance between two of its
/// instances, and advancing an instance by a given number of elements.
///
/// Mostly useful for conforming a type to the `CxxRandomAccessCollection`
/// protocol and should not generally be used directly.
///
/// - SeeAlso: https://en.cppreference.com/w/cpp/named_req/RandomAccessIterator
public protocol UnsafeCxxRandomAccessIterator: UnsafeCxxInputIterator {
  associatedtype Distance: BinaryInteger

  static func -(lhs: Self, rhs: Self) -> Distance
  static func +=(lhs: inout Self, rhs: Distance)
}

extension UnsafePointer: UnsafeCxxRandomAccessIterator
where Pointee: ~Copyable {}

extension UnsafeMutablePointer: UnsafeCxxRandomAccessIterator
where Pointee: ~Copyable {}

public protocol UnsafeCxxMutableRandomAccessIterator:
UnsafeCxxRandomAccessIterator, UnsafeCxxMutableInputIterator {}

extension UnsafeMutablePointer: UnsafeCxxMutableRandomAccessIterator
where Pointee: ~Copyable {}
