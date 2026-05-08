//
//  to.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//


import Combine
import Foundation
import UIKit
/// Base class to operate with flow using coordination pattern
open class Coordinator<M: CoordinationMeta>: NSObject {
    
    open var rootViewController: UIViewController {
        fatalError("Must override rootViewController")
    }
    /// Property to store type-erased coordinators.
    ///
    /// Access can be reached by mutating functions.
    public internal(set) var coordinators: [AnyCoordinator] = []

    /// - Important: Avaliable only after `start(with:)`.
    /// Before that it's `nil`.
    public var meta: M!

    /// Callback that triggers after `finish()`.
    public var onFinish: ((Coordinator<M>) -> Void)?

    public internal(set) weak var parent: AnyCoordinator?

    var cancelBag = Set<AnyCancellable>()
    
    override public init() { super.init() }
    // start with meta
    open func start(with meta: M) {
        self.meta = meta
    }
    // start without meta
    open func start() {
        
    }

    open func finish() {
        onFinish?(self)
    }

    // MARK: - Operations with sub-coordinators

    /// Appends `coordinators` whith a new one.
    public func add<T: CoordinationMeta, C: Coordinator<T>>(
        _ coordinator: C
    ) {
        coordinators.append(coordinator.asAny)
        coordinator.parent = asAny
    }

    /// Removes a coordiantor from `coordinators` using type.
    public func remove<T: CoordinationMeta, C: Coordinator<T>>(
        _ coordinatorType: C.Type
    ) {
        coordinators.removeAll { type(of: $0.coordinator) == coordinatorType }
    }

    /// Removes a coordiantor from `coordinators` using coordinator instance.
    public func remove<T: CoordinationMeta, C: Coordinator<T>>(
        _ coordinator: C
    ) {
        remove(type(of: coordinator))
    }

    /// Removes a coordiantor from `coordinators` using it's own meta.
    public func remove<T: CoordinationMeta>(
        _ metaType: T.Type
    ) {
        coordinators.removeAll { $0.metaType == metaType }
    }

    public func remove(_ anyCoordinator: AnyCoordinator) {
        coordinators.removeAll { $0.metaType == anyCoordinator.metaType }
    }

    /// Removes all coordiantors from `coordinators`.
    public func removeAll() {
        coordinators.removeAll()
    }
}
