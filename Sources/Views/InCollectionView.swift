//
//  InCollectionView.swift
//  BeyableClient
//
//  Created by MarKinho on 04/07/2024.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif
import WebKit

/// The class responsible for displaying the header bar campaign.
@available(iOS 13.0, *)
class InCollectionView : CampaignView, CampaignViewProtocol {
    /// Current Webview Containing the header Campaing
    var stackView : UIStackView!
    /// True if we are on a view SwiftUi
    var swiftUiCurrentView = false
    var currentViewController : UIViewController!
       
    var replacedViews: [String: UIView] = [String: UIView]()
    var originalConstraintsMap = [UIView: [NSLayoutConstraint]]()
    var internalOriginalConstraintsMap = [UIView: [NSLayoutConstraint]]()
    var originalStackConstraints : [NSLayoutConstraint]?
        
    var ctaUrlWrappers = [UrlWrapper]()
    var ctaCallbackWrappers = [CallbackWrapper]()

    private var workingWithStackView = false
    
    
    /**
     Initialize a new Header View
     - Parameter campaignDto : Current Campaign toe show
     - Parameter callBackJavascript : Variable used when there will be interactions in JavaScript.
     */
    override init(campaignDto: CampaignDTO?, viewParent: UIView?, callBackJavascript : JavascriptCallback) {
        super.init(campaignDto: campaignDto, viewParent: viewParent, callBackJavascript : callBackJavascript)
        self.createBannerView()
    }
    
    /// Show header at the top of View
    /// - Parameter height: We need this to shift view
    func showStickyHeaderView(){
        
    }
    
    func showInPageView() {
        
    }
    
    func injectViewOnCell(cell: UITableViewCell, delegate: OnCtaDelegate?) {
        LogHelper.instance.showLog(logToShow: "Start campaign injection on cell '\(cell)'")
        let injectedViewTag = "\(Int(arc4random_uniform(100000)))"
        stackView.restorationIdentifier = injectedViewTag
        let containerView = cell.contentView;
        
        // Check if we are on stackview or not
        if let foundView = ViewUtils.findSubview(view: containerView, withId: self.campaignDto.inCollectionPlacementId) {
            // We handle adding InPage in StackView
            if let parentStackView = foundView.superview as? UIStackView {
                self.workingWithStackView = true
                if let index = parentStackView.arrangedSubviews.firstIndex(of: foundView) {
                    var indexToInsertView = 0
                    // stackView.isHidden = false
                    // For the replace, we delete the element and replace it
                    if(campaignDto.inCollectionPlacement == RelativePlacement.REPLACE) {
                        indexToInsertView = index
                        replacedViews[injectedViewTag] = foundView
                        foundView.isHidden = true
                    }
                    else if(campaignDto.inCollectionPlacement == RelativePlacement.BELOW) {
                        // We need to inject after this one for 'after' option
                        indexToInsertView = index + 1
                    }
                    else if(campaignDto.inCollectionPlacement == RelativePlacement.ABOVE) {
                        if(index == 0) {
                            indexToInsertView = 0
                        }
                        else{
                            indexToInsertView = index
                        }
                    }
                    stackView.translatesAutoresizingMaskIntoConstraints = false
                    parentStackView.insertArrangedSubview(stackView, at: indexToInsertView)
                    parentStackView.layoutIfNeeded()
                }
                // Set callback if needed
                setCtaDelegate(injectedViewTag, delegate)
            } else {
                // Check le placement
                if self.campaignDto.inCollectionPlacement       == RelativePlacement.ABOVE {
                    
                }
                else if self.campaignDto.inCollectionPlacement  == RelativePlacement.LEFT {
                    
                }
                else if self.campaignDto.inCollectionPlacement  == RelativePlacement.RIGHT {
                    
                }
                if self.campaignDto.inCollectionPlacement       == RelativePlacement.BELOW {
                    
                }
                else if self.campaignDto.inCollectionPlacement == RelativePlacement.REPLACE {
                    let (replacedView, originalConstraints, internalOriginalConstraints) =
                    ViewUtils.replaceView(target:self.campaignDto.inCollectionPlacementId, on: containerView, with: stackView) ?? (nil, nil, nil)
                    if replacedView != nil && originalConstraints != nil && internalOriginalConstraints != nil {
                        replacedViews[injectedViewTag] = replacedView!
                        if originalConstraintsMap[replacedView!] == nil {
                            originalConstraintsMap[replacedView!] = originalConstraints!
                            internalOriginalConstraintsMap[replacedView!] = internalOriginalConstraints!
                        }
                        LogHelper.instance.showLog(logToShow: "ReplacedView: \(replacedView)")
                        LogHelper.instance.showLog(logToShow: "View replaced on cell '\(cell)'")
                    } else {
                        LogHelper.instance.showLog(logToShow: "Cell to be replaced not found")
                    }
                    // Si on a des contraintes de notre bannerView, on les remets
                    if originalStackConstraints != nil && stackView.superview != nil {
                        // Restore original constraints
                        NSLayoutConstraint.activate(originalStackConstraints!)
                        stackView.superview!.setNeedsLayout()
                        stackView.superview!.layoutIfNeeded()
                    }
                }
            }
        }
        // Set callback if needed
        setCtaDelegate(injectedViewTag, delegate)
    }
    
    func removeInjectedView(cell: UITableViewCell, injectedView: UIView, injectedViewId: String) {
        if self.workingWithStackView {
            LogHelper.instance.showLog(logToShow: "Removing injected view on UIstackView '\(injectedViewId)' on cell '\(cell)'")
            let replacedView = replacedViews[injectedViewId]!
            replacedView.isHidden = false
            //stackView.isHidden = true
            injectedView.removeFromSuperview()
        } else {
            LogHelper.instance.showLog(logToShow: "Removing injected view '\(injectedViewId)' on cell '\(cell)'")
            originalStackConstraints = injectedView.constraints
            let replacedView = replacedViews[injectedViewId]!
            ViewUtils.restoreOriginalView(on: cell.contentView, oldView: injectedView, originalView: replacedView, originalConstraints: self.originalConstraintsMap[replacedView]!, internalOriginalConstraints: self.internalOriginalConstraintsMap[replacedView]!)
            self.replacedViews.removeValue(forKey: injectedViewId)
            //campaignView.originalConstraintsMap.removeValue(forKey: replacedView)
            //campaignView.originalConstraintsMap.removeValue(forKey: replacedView)
        }
        
    }
    
    
    /// Rmove WebView from parents View
    public func dismissWebView(){
        stackView?.removeFromSuperview()
        stackView = nil
    }
    
    
    public func createBannerView() {
        self.stackView = UIStackView()
        self.stackView.axis = .vertical
        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        for display in self.campaignDto.displays {
            if display.componentType == DisplayComponentType.IMG_B64 {
               let imageView = UIImageView()
               imageView.translatesAutoresizingMaskIntoConstraints = false
               imageView.image = ImageUtils.decodeBase64ToImage(display.imageB64)
               imageView.contentMode = .scaleAspectFit
               NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: CGFloat(display.imageWidthPx)),
                imageView.heightAnchor.constraint(equalToConstant: CGFloat(display.imageHeightPx))
               ])
               if display.ctaIsUrl {
                   if let cta = display.cta {
                       let urlWrapper = UrlWrapper(urlString: cta)
                       if display.ctaHasInteraction {
                           urlWrapper.interaction = display.ctaInteractionValue
                       }
                       urlWrapper.campaignId = display.campaignId
                       urlWrapper.slideId = display.slideId
                       ctaUrlWrappers.append(urlWrapper)
                       let tapGesture = UITapGestureRecognizer(target: urlWrapper, action: #selector(urlWrapper.handleTap(_:)))
                       imageView.addGestureRecognizer(tapGesture)
                       imageView.isUserInteractionEnabled = true
                   }
               }
               self.stackView.addArrangedSubview(imageView)
           } else if display.componentType == DisplayComponentType.IMG_URL {
               let imageView = UIImageView()
               imageView.translatesAutoresizingMaskIntoConstraints = false
               imageView.contentMode = .scaleAspectFit
               NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: CGFloat(display.imageWidthPx)),
                imageView.heightAnchor.constraint(equalToConstant: CGFloat(display.imageHeightPx))
               ])
               imageView.load(url: URL(string: display.imageUrl)!)
               if display.ctaIsUrl {
                   if let cta = display.cta {
                       let urlWrapper = UrlWrapper(urlString: cta)
                       if display.ctaHasInteraction {
                           urlWrapper.interaction = display.ctaInteractionValue
                       }
                       urlWrapper.campaignId = display.campaignId
                       urlWrapper.slideId = display.slideId
                       ctaUrlWrappers.append(urlWrapper)
                       let tapGesture = UITapGestureRecognizer(target: urlWrapper, action: #selector(urlWrapper.handleTap(_:)))
                       imageView.addGestureRecognizer(tapGesture)
                       imageView.isUserInteractionEnabled = true
                   }
               }
               self.stackView.addArrangedSubview(imageView)
           } else if display.componentType == DisplayComponentType.TEXT  {
               let textDisplay = display.textDisplay
               let label = UILabel()
               // Configure the text
               label.text = textDisplay?.text
               // Configure the font size
               if let fontSize = Float((textDisplay?.fontSize!)!) {
                   if let fontWeight = textDisplay?.fontWeight {
                       // Convert font weight string to UIFont.Weight
                       let weight = UIFont.Weight.fromString(fontWeight)
                       label.font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: weight)
                   } else {
                       label.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
                   }
               }
               // Configure the text color
               if let color = textDisplay?.color {
                   label.textColor = UIColor(hex: color)
               }
               // Configure the background color
               if let backgroundColor = textDisplay?.backgroundColor {
                   label.backgroundColor = UIColor(hex: backgroundColor)
               }
               // Configure the text decoration (underline, strikethrough)
               if let textDecoration = textDisplay?.textDecoration {
                   var attributes: [NSAttributedString.Key: Any] = [:]
                   switch textDecoration {
                   case "underline":
                       attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                   case "strikethrough":
                       attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
                   default:
                       break
                   }
                   if !attributes.isEmpty {
                       label.attributedText = NSAttributedString(string: textDisplay!.text ?? "", attributes: attributes)
                   }
               }
               if display.ctaIsUrl {
                   if let cta = display.cta {
                       let urlWrapper = UrlWrapper(urlString: cta)
                       if display.ctaHasInteraction {
                           urlWrapper.interaction = display.ctaInteractionValue
                       }
                       urlWrapper.campaignId = display.campaignId
                       urlWrapper.slideId = display.slideId
                       ctaUrlWrappers.append(urlWrapper)
                       let tapGesture = UITapGestureRecognizer(target: urlWrapper, action: #selector(urlWrapper.handleTap(_:)))
                       label.addGestureRecognizer(tapGesture)
                       label.isUserInteractionEnabled = true
                   }
               }
               self.stackView.addArrangedSubview(label)
           } else if display.componentType == DisplayComponentType.EMPTY {
               let emptyView = UIView()
               self.stackView.addArrangedSubview(emptyView)
           }
        }
       
        self.stackView.backgroundColor = UIColor.clear
   }
    
    public func setDelegateAndGetView(_ cellId: String, _ delegate : OnCtaDelegate?) -> UIView {
        setCtaDelegate(cellId, delegate)
        return self.stackView
    }
    
    private func setCtaDelegate(_ cellId: String, _ delegate: OnCtaDelegate?) {
        if delegate != nil {
            for i in 0..<self.campaignDto.displays.count {
                let display = self.campaignDto.displays[i]
                if (display.ctaIsCallback) {
                    if i < stackView.subviews.count {
                        let callbackWrapper = CallbackWrapper(listener: delegate!, cellId: cellId, value: display.cta!)
                        if display.ctaHasInteraction {
                            callbackWrapper.interaction = display.ctaInteractionValue
                        }
                        callbackWrapper.campaignId = display.campaignId
                        callbackWrapper.slideId = display.slideId
                        ctaCallbackWrappers.append(callbackWrapper)
                        let tapGesture = UITapGestureRecognizer(target: callbackWrapper, action: #selector(callbackWrapper.handleTap(_:)))
                        stackView.subviews[i].addGestureRecognizer(tapGesture)
                        stackView.subviews[i].isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    func isTarget(_ elementId: String) -> Bool {
        return self.campaignDto.isTarget(elementId)
    }

    func isPlaceHolder(_ placeHolderId: String) -> Bool {
        return self.campaignDto.isPlaceHolder(placeHolderId)
    }
    
    func getHeight() -> CGFloat {
        var res: CGFloat = 0.0
        for display in self.campaignDto.displays {
            res += CGFloat(display.imageHeightPx)
        }
        return res
    }
    
    func getWidth() -> CGFloat {
        var res: CGFloat = 0.0
        for display in self.campaignDto.displays {
            if CGFloat(display.imageWidthPx) > res {
                res = CGFloat(display.imageWidthPx)
            }
        }
        return res
    }

}

extension UIImage {
    var base64String: String {
        return self.pngData()?.base64EncodedString() ?? ""
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}


// Wrapper pour gérer le callback
class UrlWrapper {
    
    var urlString: String
    var interaction: String?
    var campaignId: String?
    var slideId: String?
    
    init(urlString: String) {
        self.urlString = urlString;
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                LogHelper.instance.showLog(logToShow: "Invalid URL or unable to open: \(urlString)")
            }
        }
        // If we have a interaction, send it to Beyable
        if let i = interaction {
            SendViewService.instance.saveInteraction(campaignId: campaignId ?? "", slideId: slideId ?? "",
                                                     pageViewDate: StringUtils.getCurrentISO8601Date(), pageUrl: "",
                                                     interactions: [BYInteraction(eventName: "", eventValue: i),])
        }
    }
}

// Wrapper pour gérer le callback
class CallbackWrapper {
    var listener: OnCtaDelegate
    var cellId: String
    var value: String
    var interaction: String?
    var campaignId: String?
    var slideId: String?
    
    init(listener: OnCtaDelegate, cellId: String, value: String) {
        self.listener   = listener
        self.cellId     = cellId
        self.value      = value;
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        listener.onBYClick(cellId: self.cellId, value: self.value)
        // If we have a interaction, send it to Beyable
        if let i = interaction {
            SendViewService.instance.saveInteraction(campaignId: campaignId ?? "", slideId: slideId ?? "",
                                                     pageViewDate: StringUtils.getCurrentISO8601Date(), pageUrl: "",
                                                     interactions: [BYInteraction(eventName: cellId, eventValue: i),])
        }
    }
}
