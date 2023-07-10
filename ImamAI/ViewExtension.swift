//
//  ViewExtension.swift
//  ChatViewTutorial
//
//  Created by Duy Bui on 2/2/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//
import SwiftUI

extension View {
    func endEditing(_ force: Bool) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let windows = windowScene.windows
            windows.forEach { $0.endEditing(force) }
        }
    }
}
