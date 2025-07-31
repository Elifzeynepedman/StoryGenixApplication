//
//  KeyboardSafeAreaDisabler.swift
//  StoryGenix
//
//  Created by Elif Edman on 30.07.2025.
//

import SwiftUI

struct KeyboardSafeAreaDisabler<Content: View>: UIViewControllerRepresentable {
    var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let controller = UIHostingController(rootView: content)
        
        // ✅ Force full screen and ignore keyboard safe area
        controller.additionalSafeAreaInsets = .zero
        controller.view.insetsLayoutMarginsFromSafeArea = false
        controller.viewRespectsSystemMinimumLayoutMargins = false
        
        // ✅ This prevents automatic resizing when keyboard appears
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {
        uiViewController.rootView = content
    }
}
