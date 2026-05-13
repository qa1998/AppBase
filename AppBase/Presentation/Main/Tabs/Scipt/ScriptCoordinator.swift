//
//  ScriptCoordinator.swift
//  AppBase
//

import BaseMVVM
import UIKit

final class ScriptCoordinator: NavigationCoordinator<VoidMeta> {

    private let repository = ScriptRepository.shared

    private lazy var rootVC: SciptViewController = {
        let vc = SciptViewController()
        let vm = ScriptViewModel(repository: repository)
        vc.invoke(viewModel: vm)
        vc.onSelectScript = { [weak self] script in
            self?.openDetail(script: script)
        }
        return vc
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]))
    }

    private func openEditor(script: TeleprompterScript?) {
        let vc = ScriptEditorViewController(repository: repository, script: script)
        navigate(to: .push(vc))
    }

    private func openDetail(script: TeleprompterScript) {
        let vc = ScriptDetailViewController(repository: repository, script: script)
        vc.onTapEdit = { [weak self] s in
            self?.openEditor(script: s)
        }
        vc.onTapPlay = { [weak self] script in
            self?.openPlay(script: script)
        }
        navigate(to: .push(vc))
    }

    private func openPlay(script: TeleprompterScript) {
        let vc = PlayScriptViewController(script: script)
        navigate(to: .push(vc))
    }
}
