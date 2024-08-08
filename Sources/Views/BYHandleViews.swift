import Foundation
#if canImport(UIKit)
    import UIKit
#endif
import WebKit
import SwiftUI
/**
 This class manages the web view that will be displayed for Popin, InPage, and header campaigns. It also handles the calls made from JavaScript to the native code.
 */
@available(iOS 13.0, *)
public class BYHandleViews : NSObject, JavascriptCallback {
    
    /// The campaign DTO received by WS
    public var campaignsDTO: [CampaignDTO]?
    /// Current Screen
    var currentView: UIView?
    /// True if we are on a view SwiftUi
    var swiftUiCurrentView = false
    /// Save the orientation, if changed reload the compaing
    private var currentOrientation : UIDeviceOrientation?
    /// The class responsible for displaying the header bar campaign.
    private var headersView : [HeaderView] = [HeaderView]()
    /// The class responsible for displaying the inPage campaign.
    private var inPagesView : [InPageView] = [InPageView]()
    /// The class responsible for displaying the popin campaign.
    private var overlaysView : [OverlayView] = [OverlayView]()
        
    private var inCollectionCampaigns:  [CampaignDTO] = [CampaignDTO]()
    private var inCollectionViews : [String: InCollectionView] = [String: InCollectionView]()
    
    
    private var callBackService : CallBackService?
    
    public init(currentView: UIView?) {
        super.init()
        self.currentView = currentView
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), 
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    /// We call it to update our views campaing after orientation changed
    func reloadWebView(){
        if let _ = currentOrientation{
            reloadViews()
        }
    }
    
    /// We call it to update our views campaing after orientation changed
    func reloadViews(){
        for headerView in self.headersView {
            headerView.dismissWebView()
        }
        for headerView in self.inPagesView {
            headerView.dismissWebView()
        }
        for headerView in self.overlaysView {
            headerView.dismissWebView()
        }
        headersView     = [HeaderView]()
        inPagesView     = [InPageView]()
        overlaysView    = [OverlayView]()
        
        setCampagns(listCampagns: campaignsDTO ?? [CampaignDTO]())
    }
    
    /// We call it to update our views campaing after orientation changed
    @objc private func orientationDidChange() {
        let deviceOrientation = UIDevice.current.orientation
        // Traitez le changement d'orientation
        switch deviceOrientation {
        case .portrait:
            reloadWebView()
            currentOrientation = .portrait
            // Gérer l'orientation portrait
            break
        case .landscapeLeft, .landscapeRight:
            reloadWebView()
            currentOrientation = .landscapeLeft
            // Gérer l'orientation paysage
            break
        default:
            // Gérer d'autres orientations si nécessaire
            break
        }
    }
    
    
    /// Show Campaign case : Popin View
    func createNewPopinView(campaignDTO : CampaignDTO?) -> OverlayView?{
        if let c = campaignDTO {
            let newOverlayView = OverlayView(campaignDto: c, viewParent: currentView, callBackJavascript: self)
            newOverlayView.webView.scrollView.isScrollEnabled = false
            newOverlayView.addPopin()
            return newOverlayView
        }
        return nil
    }
    
    /// Show Campaign case : Header
    func createNewHeaderView(campaignDTO : CampaignDTO?) -> HeaderView? {
        if let v = self.currentView,
           let c = campaignDTO {
            let newHeaderView = HeaderView(campaignDto: c, viewParent: v, callBackJavascript: self)
            return newHeaderView
        }
        return nil
    }
    
    /// Show Campaign case : inPage
    func createNewInPageView(campaignDTO : CampaignDTO?) -> InPageView?{
        if let v = self.currentView, let c = campaignDTO {
            let newInPageView = InPageView(campaignDto: c, viewParent: v, callBackJavascript: self)
            return newInPageView
        }
        return nil
    }
    
    
    
    /// Called after used clicked on close button on the view Campaign
    /// - Parameter typeCampagne: ``TypeCampaign``
    func onClose(currentCampaign : CampaignDTO) {
        SendViewService.instance.sendAcknowledgeClosed()
        // delete the campagn we just close from the list campaign
        campaignsDTO = campaignsDTO?.filter { $0.campagnId != currentCampaign.campagnId }
        for headerView in self.headersView {
            if(headerView.campaignDto.campagnId == currentCampaign.campagnId){
                headerView.dismissWebView()
            }
        }
        for headerView in self.inPagesView {
            if(headerView.campaignDto.campagnId == currentCampaign.campagnId){
                headerView.dismissWebView()
            }
        }
        for headerView in self.overlaysView {
            if(headerView.campaignDto.campagnId == currentCampaign.campagnId){
                headerView.dismissWebView()
            }
        }
    }
    
    
    func onAction() {
        
    }
    
    /// Take campaings and create Header, InPage, Popin View for Every campaign
    /// - Parameters:
    ///   - listCampagns: listCampaigns to show
    ///   - callBackService : Used to call function like sendAck or sendClose
    func setCampagns(listCampagns : [CampaignDTO], callBackService : CallBackService? = nil){
        if let a = callBackService {
            self.callBackService = a
        }
        self.campaignsDTO = listCampagns
        // Reset what we have
        self.resetCampaignsLists()
        for campagn in listCampagns {
            // we don't show campaing if mustBeDisplayed = false but we send aknowledge
            if(campagn.mustBeDisplayed == true){
                if(campagn.typeCampagne == .HEADER){
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(campagn.displayAfter)) {
                        let newHeaderView = self.createNewHeaderView(campaignDTO: campagn)
                        if let newHeaderView = newHeaderView{
                            self.headersView.append(newHeaderView)
                        }
                    }
                }
                else if(campagn.typeCampagne == .IN_PAGE){
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(campagn.displayAfter)) {
                        let newInPageView = self.createNewInPageView(campaignDTO: campagn)
                        if let newInPageView = newInPageView {
                            self.inPagesView.append(newInPageView)
                        }
                    }
                }
                else if(campagn.typeCampagne == .OVERLAY){
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(campagn.displayAfter)) {
                        let newOverlayView = self.createNewPopinView(campaignDTO: campagn)
                        if let newOverlayView = newOverlayView {
                            self.overlaysView.append(newOverlayView)
                        }
                    }
                }
                else if(campagn.typeCampagne == .IN_COLLECTION){
                    self.inCollectionCampaigns.append(campagn)
                }
            }
            //send aknowledge
            callBackService?.sendAkn(campaignDto: campagn)
        }
        // Send it to observable (if the context is SwiftUI, someone has to answer)
        DispatchQueue.main.async {
            BYObservable.shared.updateInPageCampaigns(self.inPagesView)
            BYObservable.shared.updateCollectionCampaigns(self.inCollectionCampaigns)
        }
    }
        
    func cellBinded(cell: UITableViewCell, elementId: String, callback: OnCtaDelegate?) {
        // Tout le boulot doient etre fait sur le thread principale
        DispatchQueue.main.async {
            let campaigns = self.getCampaignsForViewHolder(elementId: elementId)
            if !campaigns.isEmpty {
                for campaign in campaigns {
                    let campaignView: InCollectionView
                    let viewKey = "\(elementId)_\(campaign.campagnId)"
                    if !self.inCollectionViews.keys.contains(viewKey) {
                        campaignView = self.createNewInCollectionView(cell.contentView, campaign)!
                        self.inCollectionViews[viewKey] = campaignView
                    } else {
                        campaignView = self.inCollectionViews[viewKey]!
                    }
                    campaignView.injectViewOnCell(cell: cell, delegate: callback)
                }
            }
        }
    }
    
    func cellUnbinded(cell: UITableViewCell, elementId: String) {
        // Tout le boulot doient etre fait sur le thread principale
        DispatchQueue.main.async {
            for campaignView in self.inCollectionViews.values {
                for viewId in campaignView.replacedViews.keys {
                    let injectedView = cell.viewWithRestorationIdentifier(viewId)
                    if injectedView != nil {
                        campaignView.removeInjectedView(cell: cell, injectedView: injectedView!, injectedViewId: viewId)
                    }
                }
            }
        }
    }
    
    func getCampaignsForViewHolder(elementId: String) -> [CampaignDTO] {
        var campaigns: [CampaignDTO] = []
        for campaign in self.inCollectionCampaigns {
            if campaign.inCollectionTargets.contains(elementId) {
                campaigns.append(campaign)
            }
        }
        return campaigns
    }
    
    func createNewInCollectionView(_ parentView: UIView, _ campaign: CampaignDTO?) -> InCollectionView? {
        if let c = campaign {
            let newInCollectionView = InCollectionView(campaignDto: c, viewParent: parentView, callBackJavascript: self)
            return newInCollectionView
        }
        return nil
    }
    
    func resetCampaignsLists(){
        DispatchQueue.main.async {
            for v in self.headersView {
                v.dismissWebView()
            }
            for v in self.inPagesView {
                v.dismissWebView()
            }
            for v in self.overlaysView {
                v.dismissWebView()
            }
            // REset the obsevable
            BYObservable.shared.inPageCampaigns = [:]
        }
        
        headersView     = [HeaderView]()
        inPagesView     = [InPageView]()
        overlaysView    = [OverlayView]()
        //inCollectionCampaigns = [inCollectionCampaigns]()
    }

}
