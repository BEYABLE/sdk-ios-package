//
//  ViewUtils.swift
//  
//
//  Created by MarKinho on 18/07/2024.
//

import Foundation
import UIKit

class ViewUtils {
    
    /// This function try to find a view by his id
    /// - Parameters:
    ///   - view: The parent view containing the view with the id id
    ///   - id:  the accessibilityIdentifier
    /// - Returns: the view with the id : id
    static func findSubview(view : UIView , withId id: String) -> UIView? {
        //Checks if the identifier of the current view matches the given string
        if view.accessibilityIdentifier == id || view.restorationIdentifier == id{
            return view
        }
        
        // Recursive traversal of subviews.
        for subview in view.subviews {
            if let foundView = findSubview(view: subview, withId: id) {
                return foundView
            }
        }
        
        // If no matching view is found, returns nil.
        return nil
    }
        

    // Méthode pour remplacer une vue
    static func replaceView(target: String, on parent: UIView, with newView: UIView) -> (UIView, [NSLayoutConstraint], [NSLayoutConstraint])? {
        // Trouver l'ancienne vue à remplacer
        guard let oldView = findSubview(view: parent, withId: target) else {
            LogHelper.instance.showLog(logToShow: "View to be replaced not found")
            return nil
        }
        var (originalConstraints, internalOriginalConstraints) =  replaceView(on: parent, oldView: oldView, with: newView) ?? (nil, nil)
        return (oldView, originalConstraints!, internalOriginalConstraints!)
    }
    
    static func replaceView(on parent: UIView, oldView: UIView, with newView: UIView) -> ([NSLayoutConstraint], [NSLayoutConstraint])? {
        // Assurez-vous que l'ancienne vue a un superview
        guard let superview = oldView.superview else {
            LogHelper.instance.showLog(logToShow: "Erreur: L'ancienne vue n'a pas de superview.")
            return nil
        }
        var originalConstraints = [NSLayoutConstraint]()
        var internalOriginalConstraints = [NSLayoutConstraint]()
                
        // Save the original constraints if not already saved
        let constraintsToRemove = superview.constraints.filter { constraint in
            (constraint.firstItem as? UIView == oldView) || (constraint.secondItem as? UIView == oldView)
        }
        originalConstraints = constraintsToRemove
        NSLayoutConstraint.deactivate(originalConstraints)
        internalOriginalConstraints = oldView.constraints
        NSLayoutConstraint.deactivate(internalOriginalConstraints)
                
        // Filtrer les contraintes internes de oldView pour ne garder que celles qui concernent ses sous-vues
        let filteredInternalConstraints = internalOriginalConstraints.filter { constraint in
            if let firstItem = constraint.firstItem as? UIView, firstItem.isDescendant(of: oldView) && (constraint.secondItem == nil || (constraint.secondItem as? UIView)?.isDescendant(of: oldView) == true) {
                return true
            }
            if let secondItem = constraint.secondItem as? UIView, secondItem.isDescendant(of: oldView) && (constraint.firstItem == nil || (constraint.firstItem as? UIView)?.isDescendant(of: oldView) == true) {
                return true
            }
            return false
        }
        
        // Get the old view's width
        let oldViewFrame = oldView.frame
        
        // Clean and remove the old view
        oldView.cleanConstraints()
        oldView.removeFromSuperview()
        
        // Add the new view to the parent
        parent.addSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        // Ajustez la taille et la position de la nouvelle vue
        newView.frame = oldViewFrame
        
        // Remap the constraints from the old view to the new view
        let newConstraints = originalConstraints.compactMap { constraint -> NSLayoutConstraint? in
            guard let firstItem = (constraint.firstItem as? UIView == oldView) ? newView : constraint.firstItem,
                  let secondItem = (constraint.secondItem as? UIView == oldView) ? newView : constraint.secondItem else {
                return nil
            }
            return NSLayoutConstraint(
                item: firstItem,
                attribute: constraint.firstAttribute,
                relatedBy: constraint.relation,
                toItem: secondItem,
                attribute: constraint.secondAttribute,
                multiplier: constraint.multiplier,
                constant: constraint.constant
            )
        }
        NSLayoutConstraint.activate(newConstraints)
        
        // Activer les contraintes internes filtrées
        let newInternalConstraints = filteredInternalConstraints.compactMap { constraint -> NSLayoutConstraint? in
            guard let firstItem = (constraint.firstItem as? UIView == oldView) ? newView : constraint.firstItem,
                  let secondItem = (constraint.secondItem as? UIView == oldView) ? newView : constraint.secondItem else {
                return nil
            }
            
            return NSLayoutConstraint(
                item: firstItem,
                attribute: constraint.firstAttribute,
                relatedBy: constraint.relation,
                toItem: secondItem,
                attribute: constraint.secondAttribute,
                multiplier: constraint.multiplier,
                constant: constraint.constant
            )
        }
        NSLayoutConstraint.activate(newInternalConstraints)
        
        parent.setNeedsLayout()
        parent.layoutIfNeeded()
                
        return (originalConstraints, internalOriginalConstraints)
    }
    
    
    
    
    
    
    
    static func restoreOriginalView(on parent: UIView, oldView: UIView, originalView: UIView, originalConstraints: [NSLayoutConstraint], internalOriginalConstraints: [NSLayoutConstraint]) {
        // Clean the constraints of the current view
        oldView.cleanConstraints()
        oldView.removeFromSuperview()
        
        // Add the original view back to the parent
        parent.addSubview(originalView)
        originalView.translatesAutoresizingMaskIntoConstraints = false
        
        // Restore original constraints
        NSLayoutConstraint.activate(originalConstraints)                
        // Restore original internal constraints
        NSLayoutConstraint.activate(internalOriginalConstraints)
                
        parent.setNeedsLayout()
        parent.layoutIfNeeded()
    }
    
    
    static func checkViewHierarchy(view1: UIView, view2: UIView) -> Bool {
        return view1.isDescendant(of: view2) || view2.isDescendant(of: view1)
    }
    
    static func insertViewAbove(parent: UIView, referenceView: UIView, newView: UIView) {
        guard let referenceIndex = parent.subviews.firstIndex(of: referenceView) else {
            return
        }

        parent.insertSubview(newView, at: referenceIndex)

        newView.translatesAutoresizingMaskIntoConstraints = false
        referenceView.translatesAutoresizingMaskIntoConstraints = false

        // Trouver la vue au-dessus de la vue de référence, s'il y en a une
        var viewAbove: UIView?
        if referenceIndex > 0 {
            viewAbove = parent.subviews[referenceIndex - 1]
        }

        // Créer des contraintes pour la nouvelle vue
        var constraints = [
            newView.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            newView.bottomAnchor.constraint(equalTo: referenceView.topAnchor)
        ]

        // Ajuster les contraintes de la vue au-dessus pour pointer sur la nouvelle vue
        if let viewAbove = viewAbove {
            for constraint in parent.constraints where constraint.firstItem as? UIView == viewAbove && constraint.firstAttribute == .bottom {
                parent.removeConstraint(constraint)
                constraints.append(NSLayoutConstraint(item: viewAbove, attribute: .bottom, relatedBy: .equal, toItem: newView, attribute: .top, multiplier: 1, constant: 0))
            }
        }

        // Activer toutes les contraintes
        NSLayoutConstraint.activate(constraints)
        parent.setNeedsLayout()
    }
    
    static func insertViewBelow(parent: UIView, referenceView: UIView, newView: UIView) {
        guard let referenceIndex = parent.subviews.firstIndex(of: referenceView) else {
            return
        }

        parent.insertSubview(newView, at: referenceIndex + 1)

        newView.translatesAutoresizingMaskIntoConstraints = false
        referenceView.translatesAutoresizingMaskIntoConstraints = false

        // Trouver la vue en dessous de la vue de référence, s'il y en a une
        var viewBelow: UIView?
        if referenceIndex < parent.subviews.count - 2 {
            viewBelow = parent.subviews[referenceIndex + 2]
        }

        // Créer des contraintes pour la nouvelle vue
        var constraints = [
            newView.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            newView.topAnchor.constraint(equalTo: referenceView.bottomAnchor)
        ]

        // Ajuster les contraintes de la vue en dessous pour pointer sur la nouvelle vue
        if let viewBelow = viewBelow {
            for constraint in parent.constraints where constraint.firstItem as? UIView == viewBelow && constraint.firstAttribute == .top {
                parent.removeConstraint(constraint)
                constraints.append(NSLayoutConstraint(item: viewBelow, attribute: .top, relatedBy: .equal, toItem: newView, attribute: .bottom, multiplier: 1, constant: 0))
            }
        }

        // Activer toutes les contraintes
        NSLayoutConstraint.activate(constraints)
        parent.setNeedsLayout()
    }
}
