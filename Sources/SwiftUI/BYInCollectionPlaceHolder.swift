//
//  BYInCollectionPlaceHolder.swift
//
//
//  Created by MarKinho on 31/07/2024.
//
import Foundation
import SwiftUI

public struct BYInCollectionPlaceHolder: View {
    let placeHolderId: String
    let elementId: String
    let delegate: OnCtaDelegate
    
    // Observable object
    @ObservedObject var beyableObservable = BYObservable.shared
    
    // Initialiseur public
    public init(placeHolderId: String, elementId: String, delegate: OnCtaDelegate) {
        self.placeHolderId = placeHolderId
        self.elementId = elementId
        self.delegate = delegate
    }
    
    public var body: some View {
        if let campaignView = beyableObservable.getCampaign(placeHolderId + "_" + elementId) {
            GeometryReader { geometry in
                let height = max(0, campaignView.getHeight())
                BYInCollectionViewRepresentable(
                    campaignView: campaignView, cellId: elementId, delegate: delegate)
                    .frame(width: geometry.size.width, height: height)
            }
            .frame(height: max(0, campaignView.getHeight()))
        } else {
            EmptyView().frame(height: 0)
        }
    }
    
    // Fonction pour valider la hauteur
    private func validHeight(for campaignView: InCollectionView) -> CGFloat {
        var height = campaignView.getHeight()
        height = max(0, height)
        return height
    }
    
    
}

struct BYInCollectionViewRepresentable: UIViewRepresentable {
    let campaignView: InCollectionView
    let cellId: String
    let delegate: OnCtaDelegate
    
    func makeUIView(context: Context) -> UIView {
        return campaignView.setDelegateAndGetView(cellId, delegate)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view if needed
    }
}

