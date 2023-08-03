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
//    @Published var locale: String = Locale.current.languageCode ?? "en"
    @Published var locale: String = UserDefaultsManager.shared.getLanguage() ?? Locale.current.languageCode ?? "en"
    
    var bundle: Bundle? {
        let b = Bundle.main.path(forResource: locale, ofType: "lproj")!
        return Bundle(path: b)
    }
    
    static func decideLocale(lang: Language) -> String{
        switch lang {
        case .english:
            return "en"
        case .arabian:
            return "ar"
        case .kazakh:
            return "kk"
        case .russian:
            return "ru"
        }
    }
    
    static func decideLanguageFromLocale(locale: String) -> String {
        switch locale {
        case "en":
            return "English"
        case "kk":
            return "Kazakh"
        case "ar":
            return "Arabian"
        case "ru":
            return "Russian"
        default:
            return "English"
        }
    }
}
