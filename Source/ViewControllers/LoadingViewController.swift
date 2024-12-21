//
//  LoadingViewController.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 13/12/2024.
//

import Foundation
import UIKit
import PureLayout

public class LoadingViewController : UIViewController {
    
    var appNameLabel: UILabel!
    var logoView: UIImageView!
    var topLabel: UILabel!
    var bottomLabel: UILabel!
    let labelStack = UIStackView()
    var topLabelTimer: Timer?
    var bottomLabelTimer: Timer?
    var switchToHomeViewTimer: Timer?
    
    var sceneState: AppStateImposer?
    
    init( sceneState: AppStateImposer? = nil ) {
        super.init(nibName: nil, bundle: nil)
        self.sceneState = sceneState
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {
        self.view = UIView()
        view.backgroundColor = .systemBlue
        
        self.appNameLabel = buildLabel()
        appNameLabel.alpha = 1
        appNameLabel.font = UIFont.systemFont(ofSize: 32)
        appNameLabel.text = PropeLocalizedString("Prope", comment: "App name")
        appNameLabel.textColor = .white
        appNameLabel.customStroke(color: UIColor(.white), width: 2.0)
        labelStack.addArrangedSubview(appNameLabel)
        //view.addSubview(appNameLabel)
        
        self.logoView = UIImageView(image: UIImage(named: "signal-logo-128-launch-screen")) //UIImageView(image: Image(systemName: "signal-logo-128-launch-screen"))
        view.addSubview(logoView)
        
        logoView.autoCenterInSuperview()
        logoView.autoSetDimensions(to: CGSize(width: 100, height: 100))
        
        
        self.topLabel = buildLabel()
        topLabel.alpha = 1
        topLabel.font = UIFont.systemFont(ofSize: 16)
        topLabel.text = PropeLocalizedString("Loading database..", comment: "Title shown while the app is updating its database.")
        labelStack.addArrangedSubview(topLabel)

        self.bottomLabel = buildLabel()
        bottomLabel.alpha = 0
        bottomLabel.font = UIFont.systemFont(ofSize: 12)
        bottomLabel.text = PropeLocalizedString("It seems your network connection is either not active or slow. Please switch to a different network or move to coveraage area", comment: "Subtitle shown while the app is updating its database.")
        labelStack.addArrangedSubview(bottomLabel)
        
        labelStack.axis = .vertical
        labelStack.alignment = .center
        labelStack.spacing = 8
         
        view.addSubview(labelStack)
        labelStack.autoPinEdge(.top, to: .bottom, of: logoView, withOffset: 20)
        labelStack.autoPinLeadingToSuperviewMargin()
        labelStack.autoPinTrailingToSuperviewMargin()
        labelStack.setCompressionResistanceHigh()
        labelStack.setContentHuggingHigh()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: .PropeAppDidBecomeActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: .PropeAppDidEnterBackground,
                                               object: nil)
        /*NotificationCenter.default.addObserver(self,
                                               selector: #selector(themeDidChange),
                                               name: .themeDidChange,
                                               object: nil)*/
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // We only show the "loading" UI if it's a slow launch. Otherwise this ViewController
        // should be indistinguishable from the launch screen.
        let kTopLabelThreshold: TimeInterval = 5
        topLabelTimer = Timer.scheduledTimer(withTimeInterval: kTopLabelThreshold, repeats: false) { [weak self] _ in
            self?.showTopLabel()
        }
        
       
        let kBottomLabelThreshold: TimeInterval = 10
        bottomLabelTimer = Timer.scheduledTimer(withTimeInterval: kBottomLabelThreshold, repeats: false) { [weak self] _ in
            self?.showBottomLabelAnimated()
        }
        
        // MARK: - Caution: Mocking app state ready!
        let kSwitchToSplitView: TimeInterval = 12
        switchToHomeViewTimer = Timer.scheduledTimer(withTimeInterval: kSwitchToSplitView, repeats: false) { [weak self] _ in
            
            self?.sceneState?.mockStateReady()
          
        }
        

        
        
    }
    
    @objc
    private func didBecomeActive() {
        AssertIsOnMainThread()
        
        
    }
    
    private var viewHasEnteredBackground = false
    
    @objc
    private func didEnterBackground() {
        AssertIsOnMainThread()
        
        viewHasEnteredBackground = true
    }
    
    private func showAppTitle() {
        appNameLabel.layer.removeAllAnimations()
        appNameLabel.alpha = 0.2
        UIView.animate(withDuration: 0.8, delay: 1, options: [.curveEaseInOut], animations: {self.appNameLabel.alpha = 1 })
        
    }
    
    private func showTopLabel() {
        topLabel.layer.removeAllAnimations()
        topLabel.alpha = 0.2
        UIView.animate(withDuration: 0.9, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut], animations: {
            self.topLabel.alpha = 1.0
        }, completion: nil)
    }

    private func showBottomLabel() {
        bottomLabel.layer.removeAllAnimations()
        self.bottomLabel.alpha = 1
    }
    
    private let kMinAlpha: CGFloat = 0.1

    private func showBottomLabelAnimated() {
        bottomLabel.layer.removeAllAnimations()
        bottomLabel.alpha = kMinAlpha
        UIView.animate(withDuration: 0.1) {
            self.bottomLabel.alpha = 1
        }
    }
    // MARK: Orientation

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .pad ? .all : .portrait
    }
    
    private func buildLabel() -> UILabel {
        let label = UILabel()

        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping

        return label
    }
    
    
}
