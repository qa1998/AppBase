//
//  RecordCoordinator.swift
//  AppBase
//

import BaseMVVM
import UIKit

final class RecordCoordinator: NavigationCoordinator<VoidMeta> {

    private lazy var rootVC: RecordViewController = {
        let vc = RecordViewController()
        let vm = RecordViewModel()
        vc.invoke(
            viewModel: vm
        )
        vc.onSelectScript = {
            [weak self]
            script in

            self?.openRecordScript(
                script: script
            )
        }
        return vc
    }()

    override func start() {
        super.start()
        navigate(
            to: .set(
                [
                    rootVC
                ]
            )
        )
    }

    private func openRecordScript(
        script: TeleprompterScript
    ) {

        let vc =
            RecordScriptViewController(
                script: script
            )

        navigate(
            to: .push(vc)
        )
    }
}
