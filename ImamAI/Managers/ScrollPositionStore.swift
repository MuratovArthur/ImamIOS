//
//  ScrollPositionStore.swift
//  ImamAI
//
//  Created by Muratov Arthur on 15.07.2023.
//

import Foundation
import SwiftUI

class ScrollPositionStore: ObservableObject {
    @Published var position: CGFloat = 0
}
