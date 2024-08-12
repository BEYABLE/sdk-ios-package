//
//  InPageView.swift
//
//
//  Created by Ouamassi Brahim on 08/02/2024.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif
import WebKit

/// Handle In page View Campaign
class InPageView : CampaignView, CampaignViewProtocol {
    /// Current Webview Containing the InPage Campaing
    var webView : WKWebView!
    var containerView: UIView!
    var heightConstraint: NSLayoutConstraint!
    var calculateHeight: CGFloat = 0.0
    
    /**
     Initialize a new Header View
     - Parameter campaignDto : Current Campaign toe show
     - Parameter viewParent : Current View Parent
     - Parameter callBackJavascript : Variable used when there will be interactions in JavaScript.
     */
    override init(campaignDto: CampaignDTO?, viewParent: UIView?, callBackJavascript : JavascriptCallback) {
        super.init(campaignDto: campaignDto, viewParent: viewParent, callBackJavascript : callBackJavascript)
        self.webView = self.initWebView(campaignCallBack: self)
    }
    
    deinit {
        //webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.bounds))
    }

    /// The view InPage will either be added alongside (to the right or left) or at the bottom/top of another view, or it will replace a view.
    /// The value defining the position is : campaignDto.elementSelector
    /// Depending on the parent view, the complexity of the processing will vary. Currently, we are only handling the case of a parent stackView.
    func showInPageView(){
        LogHelper.instance.showLog(logToShow: "Trying to show campaign \(campaignDto.campaignName) on target \(campaignDto.elementSelector ?? "NO TARGET") with placement \(campaignDto.positionInPage)")
        // Avoid showing page two times
        //campaignDto.alreadyShowen = true
        if let foundView = ViewUtils.findSubview(view: viewParent, withId: campaignDto.elementSelector ?? "") {
            // We handle adding InPage in StackView
            if let parentStackView = foundView.superview as? UIStackView {
                if let index = parentStackView.arrangedSubviews.firstIndex(of: foundView) {
                    var indexToInsertView = 0
                    // For the replace, we delete the element and replace it
                    if(campaignDto.positionInPage == RelativePlacement.REPLACE){
                        indexToInsertView = index
                        foundView.removeFromSuperview()
                    }
                    else if(campaignDto.positionInPage == RelativePlacement.BELOW){
                        // We need to inject after this one for 'after' option
                        indexToInsertView = index + 1
                    }
                    else if(campaignDto.positionInPage == RelativePlacement.ABOVE){
                        if(index == 0) {
                            indexToInsertView = 0
                        }
                        else{
                            indexToInsertView = index
                        }
                    }
                    // Créez une vue conteneur
                    containerView = UIView()
                    containerView.translatesAutoresizingMaskIntoConstraints = false
                    // Ajoutez la webView au conteneur
                    containerView.addSubview(webView)
                    // Désactiver la gestion automatique des contraintes pour la webView
                    webView.translatesAutoresizingMaskIntoConstraints = false
                    // Contrainte de hauteur pour la webView (celle-ci sera mise à jour dynamiquement)
                    heightConstraint = webView.heightAnchor.constraint(equalToConstant: 0)
                    heightConstraint.isActive = true
                    // Ajouter des contraintes pour attacher la webView au conteneur
                    NSLayoutConstraint.activate([
                        webView.topAnchor.constraint(equalTo: containerView.topAnchor),
                        webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                        webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                        webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
                    ])
                    parentStackView.insertArrangedSubview(containerView, at: indexToInsertView)
                    parentStackView.layoutIfNeeded()
                    
                    correctWebViewHeight()
                    // Ajouter un observateur de propriété
                    // webView?.addObserver(self, forKeyPath: #keyPath(WKWebView.bounds), options: [.new, .old], context: nil)
                }
                else {
                    LogHelper.instance.showLog(
                        logToShow: "The view with id \(campaignDto.elementSelector ?? "") was not found in the parent StackView.")
                }
            }
            else {
                if (foundView.superview != nil) {
                    if(campaignDto.positionInPage == RelativePlacement.BELOW){
                        ViewUtils.insertViewBelow(parent: foundView.superview!, referenceView: foundView, newView: webView)
                    }
                    else if(campaignDto.positionInPage == RelativePlacement.ABOVE){
                        ViewUtils.insertViewAbove(parent: foundView.superview!, referenceView: foundView, newView: webView)
                    }
                    else if(campaignDto.positionInPage == RelativePlacement.REPLACE) {
                        ViewUtils.replaceView(on: foundView.superview!, oldView: foundView, with: webView)
                    }
                } else {
                    LogHelper.instance.showLog(logToShow: "No superview found on referenced view")
                }
            }
        } else {
            LogHelper.instance.showLog(logToShow: "No View was find with this id = \(campaignDto.elementSelector ?? "")")
        }
    }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.bounds) {
            // Vérifier si la webView est toujours visible
            if webView?.bounds.size == .zero {
                clearWebView()
            }
        }
    }
    
    func clearWebView() {
        webView?.stopLoading()
        webView?.load(URLRequest(url: URL(string: "about:blank")!))
        BYObservable.shared.inPageCampaigns.removeValue(forKey: campaignDto.elementSelector!)
    }
    
    func showStickyHeaderView() {
        
    }
    
    /// Rmove WebView from parents View
    public func dismissWebView(){
        webView?.removeFromSuperview()
        webView = nil
    }
            
    func correctWebViewHeight() {
        webView.evaluateJavaScript("document.getElementsByClassName('by_outer')[0].offsetHeight") { [weak self] result, error in
            guard let self = self else { return }
            if let height = result as? CGFloat {
                DispatchQueue.main.async {
                    self.heightConstraint.constant = height
                    self.webView.frame.size.height = height
                    self.webView.setNeedsLayout()
                    if let p = self.webView.superview {
                        p.layoutIfNeeded()
                    }
                }
            } else if let error = error {
                LogHelper.instance.showLog(logToShow: "Error evaluating JavaScript: \(error)")
            }
        }
    }
}
