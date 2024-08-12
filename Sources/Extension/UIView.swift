//
//  UIView.swift
//
//
//  Created by MarKinho on 27/07/2024.
//

import UIKit

extension UIView {
    
    func viewWithRestorationIdentifier(_ identifier: String) -> UIView? {
        //Checks if the identifier of the current view matches the given string
        if self.accessibilityIdentifier == identifier || self.restorationIdentifier == identifier {
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
    
    // Retourne toutes les contraintes associées à la vue.
    var allConstraints: [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: self.constraints)
        if let superview = self.superview {
            constraints.append(contentsOf: superview.constraints.filter {
                ($0.firstItem as? UIView == self || $0.secondItem as? UIView == self)
            })
        }
        return constraints
    }

    // Fonction pour retirer les contraintes conflictuelles
    func removeConflictingConstraints() {
        let allConstraints = self.allConstraints
        let conflictingConstraints = allConstraints.filter { constraint in
            guard let firstItem = constraint.firstItem as? UIView,
                  let secondItem = constraint.secondItem as? UIView else {
                return false
            }
            return !firstItem.isDescendant(of: self) || !secondItem.isDescendant(of: self)
        }
        self.removeConstraints(conflictingConstraints)
    }
}
