//
//  NSLayoutConstraint.swift
//
//
//  Created by MarKinho on 12/08/2024.
//

import UIKit

extension NSLayoutConstraint {
    
    var isConfliting: Bool {
        // Vérifie si les éléments de la contrainte sont les mêmes
        if firstItem === secondItem {
            return true
        }
        // Vérifie si les attributs des contraintes sont valides
        guard let firstItem = firstItem as? UIView, let secondItem = secondItem as? UIView else {
            return false
        }
        // Vérifie si les vues sont dans la même hiérarchie
        if !firstItem.isDescendant(of: secondItem.superview!) && !secondItem.isDescendant(of: firstItem.superview!) {
            return true
        }
        
        return false
    }
}
