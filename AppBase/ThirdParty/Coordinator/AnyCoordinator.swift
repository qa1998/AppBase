//
//  AnyCoordinator.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//


import Foundation

/// Type erasure for `Coordinator`
public class AnyCoordinator {
    public let coordinator: Any
    public var metaType: CoordinationMeta.Type
    public let id: String

    public func remove(_ anyCoordinator: AnyCoordinator) {
        removeAction(anyCoordinator)
    }

    private let removeAction: (AnyCoordinator) -> Void

    public init<M: CoordinationMeta, C: Coordinator<M>>(_ coordinator: C) {
        self.coordinator = coordinator
        removeAction = { [unowned coordinator] anyCoordinator in
            coordinator.remove(anyCoordinator)
        }
        metaType = M.self
        id = String(describing: C.self)
    }
}

extension AnyCoordinator: Equatable, Hashable {
    public static func == (lhs: AnyCoordinator, rhs: AnyCoordinator) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension Coordinator {
    var asAny: AnyCoordinator {
        AnyCoordinator(self)
    }
}
