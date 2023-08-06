import SwiftUI

struct CalendarButtonView: View {
    @EnvironmentObject private var globalData: GlobalData
    @State var isIslamic = false
    
    let currentDate: Date
    
    var islamicDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .islamicUmmAlQura)
        return formatter
    }
    
    var gregorianDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        let locale = getLocale()
        formatter.locale = Locale(identifier: locale)
        formatter.dateStyle = .medium
        return formatter
    }
    
    init(currentDate: Date) {
        self.currentDate = currentDate
    }
    
    private func getLocale() -> String {
        let locale = UserDefaultsManager.shared.getLanguage() ?? GlobalData.decideLocale(lang: globalData.appLanguage)
        
        switch locale {
        case "ru":
            return "ru_RU"
        case "ar":
            return "ar_AR"
        case "kk":
            return "kk_KK"
        default:
            return "en_EN"
        }
    }
    
    let islamicMonths = [
        1: "Muharram",
        2: "Safar",
        3: "Rabi' al-Awwal",
        4: "Rabi' al-Thani",
        5: "Jumada al-Awwal",
        6: "Jumada al-Thani",
        7: "Rajab",
        8: "Sha'ban",
        9: "Ramadan",
        10: "Shawwal",
        11: "Dhu al-Qi'dah",
        12: "Dhu al-Hijjah"
    ]
    
    var body: some View {
        Button(action: {
            self.isIslamic.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color(UIColor.systemGray6))
                    .frame(width: calculateButtonWidth()+UIScreen.main.bounds.width*0.15,
                           height: UIScreen.main.bounds.height * 0.05)
                
                VStack(alignment: .leading) { // Set alignment to .leading
                    HStack() {
                        Image(systemName: "calendar")
                            .font(.subheadline)
                            .padding(.leading)
                        
                        Text(isIslamic ? formatIslamicDate(date: currentDate) : gregorianDateFormatter.string(from: currentDate))
                            .font(.body)
                            .padding(.trailing)
                        
                    }
                    
                }
            }
            .padding(8)
            .foregroundColor(Color.black)
        }
    }
    
    func formatIslamicDate(date: Date) -> String {
        let formatter = islamicDateFormatter
        let locale = getLocale()
        formatter.locale = Locale(identifier: locale)
        
        let components = formatter.calendar.dateComponents([.year, .month, .day], from: date)
        if let day = components.day, let month = components.month, let year = components.year, let monthName = islamicMonths[month] {
            return "\(monthName) \(day), \(year)"
        } else {
            return "Date formatting error"
        }
    }
    
    private func calculateButtonWidth() -> CGFloat {
        let text = isIslamic ? formatIslamicDate(date: currentDate) : gregorianDateFormatter.string(from: currentDate)
        let textWidth = text.size(withAttributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]).width
        let horizontalPadding: CGFloat = 40 // Adjust the padding value as needed
        
        return textWidth + horizontalPadding
    }
}
