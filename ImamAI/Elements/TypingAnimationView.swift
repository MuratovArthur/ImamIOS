import SwiftUI

struct TypingAnimationView: View {
    @State private var dotCount = 1
    private let maxDotCount = 3
    private let animationDuration = 0.5
    
    var body: some View {
        HStack {
            Text("Имам печатает" + String(repeating: ".", count: dotCount))
                .animation(Animation.easeInOut(duration: animationDuration).repeatForever())
                .onAppear {
                    startAnimation()
                }
            Spacer()
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { timer in
            dotCount = (dotCount % maxDotCount) + 1
        }
    }
}
