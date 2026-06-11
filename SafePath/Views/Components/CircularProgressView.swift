import SwiftUI

/// A reusable circular progress ring with a centered label.
struct CircularProgressView: View {
    let progress: Double   // 0.0 – 1.0
    let text: String       // Center label, e.g. "2/6"

    private let lineWidth: CGFloat = 8
    private let size: CGFloat = 80

    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(Color.blue.opacity(0.12), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    Color.blue,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)
                .frame(width: size, height: size)

            // Center label
            Text(text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
        }
    }
}

#Preview {
    CircularProgressView(progress: 0.6, text: "3/5")
}
