//
//  NSLayoutConstraint.swift
//
//
//  Created by MarKinho on 12/08/2024.
//

import UIKit

extension NSLayoutConstraint {
    /// Fonction pour vérifier si une contrainte est valide dans la nouvelle hiérarchie de vues
    func isValid(in newView: UIView) -> Bool {
        guard let firstItem = self.firstItem as? UIView, firstItem.isDescendant(of: newView) || firstItem == newView else {
            return false
        }
        if let secondItem = self.secondItem as? UIView {
            return secondItem.isDescendant(of: newView) || secondItem == newView
        }
        return true
    }
}
