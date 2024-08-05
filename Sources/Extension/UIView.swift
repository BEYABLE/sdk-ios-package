//
//  UIView.swift
//
//
//  Created by MarKinho on 27/07/2024.
//

import UIKit

extension UIView {
    
    func viewWithRestorationIdentifier(_ identifier: String) -> UIView? {
        if let restorationIdentifier = self.restorationIdentifier, restorationIdentifier == identifier{
            return self
        }
        
        for subview in self.subviews {
            if let foundView = subview.viewWithRestorationIdentifier(identifier) {
                return foundView
            }
        }
        
        return nil
    }
        
    // Supprime toutes les contraintes associées directement à la vue et dans la supervue
    func cleanConstraints() {
        // Supprimer les contraintes associées directement à la vue
        removeConstraints(constraints)
        
        // Supprimer les contraintes associées à la vue dans la superview
        if let superview = superview {
            let constraintsToRemove = superview.constraints.filter { constraint in
                return (constraint.firstItem as? UIView == self) || (constraint.secondItem as? UIView == self)
            }
            
            // Assurez-vous que les contraintes à supprimer existent dans la supervue
            if !constraintsToRemove.isEmpty {
                superview.removeConstraints(constraintsToRemove)
            }
        }
    }
}
