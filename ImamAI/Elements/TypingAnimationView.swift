import SwiftUI

struct TypingAnimationView: View {
    @State private var dotCount = 1
    @EnvironmentObject private var globalData: GlobalData
    private let maxDotCount = 3
    private let animationDuration = 0.5
    
    
    var body: some View {
        HStack {
//            Text(NSLocalizedString("imam-is-typing", bundle: globalData.bundle ?? Bundle.main, comment: "chat screen") + String(repeating: ".", count: dotCount))
//                .animation(Animation.easeInOut(duration: animationDuration).repeatForever())
//                .onAppear {
//                    startAnimation()
//                }
//                .foregroundColor(.gray)
//            Spacer()
            Text(NSLocalizedString("imam-is-typing", bundle: globalData.bundle ?? Bundle.main, comment: "chat screen"))
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { timer in
            dotCount = (dotCount % maxDotCount) + 1
        }
    }
}
