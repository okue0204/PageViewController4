//
//  UIView.swift
//  PageViewController4
//
//  Created by 奥江英隆 on 2024/05/26.
//

import Foundation
import UIKit

extension UIView {
    func loadNib() {
        let bundle = Bundle(for: type(of: self))
        guard let view = UINib(nibName: String(describing: Self.self), bundle: bundle).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
}
