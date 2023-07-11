import SwiftUI

struct IslamicEventListView: View {
    let events: [IslamicEvent]

    var body: some View {
        VStack{
            Text("Календарь праздников 2023:")
                .font(.headline)
                .padding()
            ScrollView (.vertical, showsIndicators: false){
                ForEach(events) { event in
                    EventListItemView(event: event)
                }
            }
        
        }
    }
}

struct EventListItemView: View {
    let event: IslamicEvent
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(.black)
                    .frame(width: 50, height: 50)
                VStack(alignment: .center, spacing: 4) {
                    Text("\(event.dayByOrdinaryCalendar)")
                        .font(.headline)
                        .foregroundColor(.white) // Change the text color to white
                    Text(String(event.monthByOrdinaryCalendar.prefix(3).uppercased()))
                        .font(.caption)
                        .foregroundColor(.white) // Change the text color to white
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.headline)
                    .bold()
                Text("\(event.dayByMuslimCalendar) \(event.monthByMuslimCalendar), \(event.yearByMuslimCalendar)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer() // Add Spacer to align the view to the left
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}






struct IslamicEvent: Identifiable {
    let id = UUID()
    let dayByMuslimCalendar: Int
    let monthByMuslimCalendar: String
    let yearByMuslimCalendar: Int
    let dayByOrdinaryCalendar: Int
    let monthByOrdinaryCalendar: String
    let dayOfWeekByOrdinaryCalendar: String
    let name: String
}

// Example data
let events: [IslamicEvent] = [
    IslamicEvent(dayByMuslimCalendar: 1, monthByMuslimCalendar: "Мухаррам", yearByMuslimCalendar: 1445, dayByOrdinaryCalendar: 1, monthByOrdinaryCalendar: "Август", dayOfWeekByOrdinaryCalendar: "Понедельник", name: "Исламский Новый Год"),
    IslamicEvent(dayByMuslimCalendar: 10, monthByMuslimCalendar: "Мухаррам", yearByMuslimCalendar: 1445, dayByOrdinaryCalendar: 10, monthByOrdinaryCalendar: "Август", dayOfWeekByOrdinaryCalendar: "Среда", name: "День Ашуры"),
    IslamicEvent(dayByMuslimCalendar: 12, monthByMuslimCalendar: "Раби аль-Аввал", yearByMuslimCalendar: 1445, dayByOrdinaryCalendar: 12, monthByOrdinaryCalendar: "Август", dayOfWeekByOrdinaryCalendar: "Пятница", name: "Милад-ун-Наби"),
    IslamicEvent(dayByMuslimCalendar: 20, monthByMuslimCalendar: "Раби аль-Ахир", yearByMuslimCalendar: 1445, dayByOrdinaryCalendar: 18, monthByOrdinaryCalendar: "Август", dayOfWeekByOrdinaryCalendar: "Воскресенье", name: "Вознесение Пророка"),
    IslamicEvent(dayByMuslimCalendar: 1, monthByMuslimCalendar: "Раджаб", yearByMuslimCalendar: 1445, dayByOrdinaryCalendar: 25, monthByOrdinaryCalendar: "Август", dayOfWeekByOrdinaryCalendar: "Вторник", name: "Лайлат аль-Исра"),
    IslamicEvent(dayByMuslimCalendar: 1, monthByMuslimCalendar: "Рамадан", yearByMuslimCalendar: 1445, dayByOrdinaryCalendar: 10, monthByOrdinaryCalendar: "Сентябрь", dayOfWeekByOrdinaryCalendar: "Четверг", name: "Начало Рамадана"),
    IslamicEvent(dayByMuslimCalendar: 27, monthByMuslimCalendar: "Рамадан", yearByMuslimCalendar: 1445, dayByOrdinaryCalendar: 5, monthByOrdinaryCalendar: "Октябрь", dayOfWeekByOrdinaryCalendar: "Пятница", name: "Лайлат аль-Кадр"),
    IslamicEvent(dayByMuslimCalendar: 1, monthByMuslimCalendar: "Шавваль", yearByMuslimCalendar: 1445, dayByOrdinaryCalendar: 30, monthByOrdinaryCalendar: "Октябрь", dayOfWeekByOrdinaryCalendar: "Суббота", name: "Ид аль-Фитр"),
    IslamicEvent(dayByMuslimCalendar: 9, monthByMuslimCalendar: "Зуль-хиджа", yearByMuslimCalendar: 1445, dayByOrdinaryCalendar: 20, monthByOrdinaryCalendar: "Ноябрь", dayOfWeekByOrdinaryCalendar: "Среда", name: "День Арафа"),
    IslamicEvent(dayByMuslimCalendar: 10, monthByMuslimCalendar: "Зуль-хиджа", yearByMuslimCalendar: 1445, dayByOrdinaryCalendar: 21, monthByOrdinaryCalendar: "Ноябрь", dayOfWeekByOrdinaryCalendar: "Четверг", name: "Ид аль-Адха"),
    IslamicEvent(dayByMuslimCalendar: 10, monthByMuslimCalendar: "Зуль-хиджа", yearByMuslimCalendar: 1445, dayByOrdinaryCalendar: 21, monthByOrdinaryCalendar: "Ноябрь", dayOfWeekByOrdinaryCalendar: "Четверг", name: "Ид аль-Адха"),
    IslamicEvent(dayByMuslimCalendar: 10, monthByMuslimCalendar: "Зуль-хиджа", yearByMuslimCalendar: 1445, dayByOrdinaryCalendar: 21, monthByOrdinaryCalendar: "Ноябрь", dayOfWeekByOrdinaryCalendar: "Четверг", name: "Ид аль-Адха"),
]



struct IslamicEventListView_Previews: PreviewProvider {
    static var previews: some View {
        IslamicEventListView(events: events)
    }
}
