//
//  Weak.swift
//
//
//  Created by MarKinho on 26/07/2024.
//

class Weak<T: AnyObject> {
    weak var value: T?
    init(value: T) {
        self.value = value
    }
}
