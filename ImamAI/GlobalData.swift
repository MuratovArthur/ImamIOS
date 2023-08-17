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
    case arabic = "Arabic"
}

class GlobalData: ObservableObject {
    @Published var appLanguage: Language = .english
    @Published var locale: String = UserDefaultsManager.shared.getLanguage() ?? Locale.current.languageCode ?? "en"
    @Published var city: String = UserDefaultsManager.shared.getCity() ?? "Almaty"
    @Published var country: String = UserDefaultsManager.shared.getCountry() ?? "Kazakhstan"
    @Published var prayerTimeMethod: Int = UserDefaultsManager.shared.getPrayerTimeMethod() ?? 2
    
    var bundle: Bundle? {
        let b = Bundle.main.path(forResource: locale, ofType: "lproj")!
        return Bundle(path: b)
    }
    
    static func decideLocale(lang: Language) -> String{
        switch lang {
        case .english:
            return "en"
        case .arabic:
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
            return "Arabic"
        case "ru":
            return "Russian"
        default:
            return "English"
        }
    }
}
