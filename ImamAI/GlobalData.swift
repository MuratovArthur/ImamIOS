//
//  GlobalData.swift
//  ImamAI
//
//  Created by Nurali Rakhay on 03.08.2023.
//

import Foundation

enum Language: String, CaseIterable {
    case english = "English"
    case russian = "Russian"
    case kazakh = "Kazakh"
    case arabian = "Arabian"
    
}

class GlobalData: ObservableObject {
    @Published var appLanguage: Language = .english
}
