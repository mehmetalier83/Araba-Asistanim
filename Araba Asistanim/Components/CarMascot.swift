import SwiftUI

/// The "Konuşan Araç" mascot from the app icon, drawn live so it can idle:
/// it floats gently, blinks every few seconds and its spark twinkles. The
/// geometry matches `Config/AppIcon/render_icon.swift` (a 1024 canvas, of
/// which the mark occupies the 690-point square starting at 167,150).
/// With Reduce Motion, or `animates: false`, it is drawn still.
struct CarMascot: View {
    var animates = true
    /// Extra glow behind the mark; off where it sits on a light surface.
    var glows = true
    /// Eyes shut in a content curve — the mascot "looks away" while a
    /// password is being typed.
    var eyesClosed = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isAnimating: Bool { animates && !reduceMotion }

    var body: some View {
        TimelineView(.animation(paused: !isAnimating)) { context in
            let t = isAnimating ? context.date.timeIntervalSinceReferenceDate : 0
            Canvas { ctx, size in
                draw(in: &ctx, size: size, time: t)
            }
            .offset(y: isAnimating ? sin(t * 1.6) * 6 : 0)
        }
        .aspectRatio(1, contentMode: .fit)
        .background {
            if glows {
                Circle()
                    .fill(AppColors.mascotViolet.opacity(0.45))
                    .blur(radius: 50)
                    .scaleEffect(0.8)
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: - Drawing

    private func draw(in ctx: inout GraphicsContext, size: CGSize, time t: Double) {
        let scale = min(size.width, size.height) / 690
        ctx.scaleBy(x: scale, y: scale)
        ctx.translateBy(x: -167, y: -150)

        let gradient = GraphicsContext.Shading.linearGradient(
            Gradient(colors: [AppColors.mascotIndigo, AppColors.mascotViolet]),
            startPoint: .zero,
            endPoint: CGPoint(x: 1024, y: 1024)
        )

        ctx.fill(Self.body, with: .color(.white))
        ctx.fill(Self.tyres, with: .color(.white))

        var windshield = ctx
        windshield.opacity = 0.18
        windshield.fill(Self.windshield, with: gradient)

        // A blink every ~4.5 s: the eyes squash vertically for 0.18 s.
        let phase = t.truncatingRemainder(dividingBy: 4.5)
        let blink = phase < 0.18 ? max(0.08, abs(phase / 0.09 - 1)) : 1
        for center in [CGPoint(x: 330, y: 640), CGPoint(x: 694, y: 640)] {
            if eyesClosed {
                var lid = Path()
                lid.move(to: CGPoint(x: center.x - 44, y: center.y - 6))
                lid.addQuadCurve(to: CGPoint(x: center.x + 44, y: center.y - 6), control: CGPoint(x: center.x, y: center.y + 34))
                ctx.stroke(lid, with: gradient, style: StrokeStyle(lineWidth: 24, lineCap: .round))
                continue
            }
            let eye = CGRect(x: center.x - 54, y: center.y - 54 * blink, width: 108, height: 108 * blink)
            ctx.fill(Path(ellipseIn: eye), with: gradient)
            if blink > 0.6 {
                ctx.fill(Path(ellipseIn: CGRect(x: center.x, y: center.y - 32, width: 32, height: 32)), with: .color(.white))
            }
        }

        ctx.stroke(Self.smile, with: gradient, style: StrokeStyle(lineWidth: 30, lineCap: .round))

        // The spark breathes and turns slightly.
        let twinkle = 1 + 0.12 * sin(t * 2.4)
        var spark = ctx
        spark.translateBy(x: 512, y: 226)
        spark.rotate(by: .degrees(8 * sin(t * 1.2)))
        spark.scaleBy(x: twinkle, y: twinkle)
        spark.translateBy(x: -512, y: -226)
        spark.fill(Self.sparkle, with: .color(.white))
    }

    // MARK: - Shapes (1024 canvas, y down)

    private static let body = Path { path in
        path.move(to: CGPoint(x: 250, y: 560))
        path.addLine(to: CGPoint(x: 300, y: 380))
        path.addQuadCurve(to: CGPoint(x: 380, y: 320), control: CGPoint(x: 318, y: 320))
        path.addLine(to: CGPoint(x: 644, y: 320))
        path.addQuadCurve(to: CGPoint(x: 724, y: 380), control: CGPoint(x: 706, y: 320))
        path.addLine(to: CGPoint(x: 774, y: 560))
        path.addQuadCurve(to: CGPoint(x: 820, y: 630), control: CGPoint(x: 820, y: 580))
        path.addLine(to: CGPoint(x: 820, y: 740))
        path.addQuadCurve(to: CGPoint(x: 790, y: 770), control: CGPoint(x: 820, y: 770))
        path.addLine(to: CGPoint(x: 234, y: 770))
        path.addQuadCurve(to: CGPoint(x: 204, y: 740), control: CGPoint(x: 204, y: 770))
        path.addLine(to: CGPoint(x: 204, y: 630))
        path.addQuadCurve(to: CGPoint(x: 250, y: 560), control: CGPoint(x: 204, y: 580))
        path.closeSubpath()
    }

    private static let tyres = Path { path in
        for x: CGFloat in [250, 664] {
            path.addRoundedRect(in: CGRect(x: x, y: 770, width: 110, height: 70), cornerSize: CGSize(width: 26, height: 26))
        }
    }

    private static let windshield = Path { path in
        path.move(to: CGPoint(x: 330, y: 540))
        path.addLine(to: CGPoint(x: 362, y: 410))
        path.addQuadCurve(to: CGPoint(x: 400, y: 380), control: CGPoint(x: 370, y: 380))
        path.addLine(to: CGPoint(x: 624, y: 380))
        path.addQuadCurve(to: CGPoint(x: 662, y: 410), control: CGPoint(x: 654, y: 380))
        path.addLine(to: CGPoint(x: 694, y: 540))
        path.closeSubpath()
    }

    private static let smile = Path { path in
        path.move(to: CGPoint(x: 440, y: 680))
        path.addQuadCurve(to: CGPoint(x: 584, y: 680), control: CGPoint(x: 512, y: 735))
    }

    private static let sparkle = Path { path in
        path.move(to: CGPoint(x: 512, y: 150))
        path.addCurve(to: CGPoint(x: 588, y: 226), control1: CGPoint(x: 521, y: 200), control2: CGPoint(x: 538, y: 217))
        path.addCurve(to: CGPoint(x: 512, y: 302), control1: CGPoint(x: 538, y: 235), control2: CGPoint(x: 521, y: 252))
        path.addCurve(to: CGPoint(x: 436, y: 226), control1: CGPoint(x: 503, y: 252), control2: CGPoint(x: 486, y: 235))
        path.addCurve(to: CGPoint(x: 512, y: 150), control1: CGPoint(x: 486, y: 217), control2: CGPoint(x: 503, y: 200))
        path.closeSubpath()
    }
}

#Preview {
    CarMascot()
        .frame(width: 220)
        .padding(40)
        .background(LinearGradient.mascot())
}
