//
//  BaseViewController.swift
//  BaseMVVM
//
//  Created by QuangAnh on 8/5/26.
//
import UIKit

open class BaseViewController<VM: BaseViewModel>: UIViewController {
    
    public var viewModel: VM {
        if _viewModel != nil {
            return _viewModel
        }
        fatalError("Must invoke \(String(describing: VM.self))")
    }
    
    private var _viewModel: VM!
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        #if DEBUG
        print("❇️\(type(of: self)) init")
        #endif
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        #if DEBUG
        print("❇️\(type(of: self)) init")
        #endif
    }
    
    deinit {
        #if DEBUG
        print("🟥\(type(of: self)) deinit")
        #endif
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        onBind()
        _viewModel.viewModelDidReady()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _viewModel.viewModelWillActive()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _viewModel.viewModelDidActive()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _viewModel.viewModelWillInactive()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _viewModel.viewModelDidInactive()
    }
    
    open func setupUI() {
        
    }
    
    open func onBind() {
        
    }
    
    public func invoke(viewModel: VM) {
        _viewModel = viewModel
    }
    
    @objc public func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

