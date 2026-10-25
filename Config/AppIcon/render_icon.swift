// Renders the CarLog AI app icon (a speedometer gauge with an AI spark) as
// opaque 1024×1024 PNGs for the AppIcon set, plus the in-app logo image.
//
//   swift Config/AppIcon/render_icon.swift
//
// Run from the repository root; it overwrites the PNGs in Assets.xcassets.

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let assets = "Araba Asistanim/Assets.xcassets"

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha
    )
}

struct Palette {
    var backgroundTop: CGColor
    var backgroundBottom: CGColor
    var track: CGColor
    var arcStart: CGColor
    var arcEnd: CGColor
    var needle: CGColor
    var spark: CGColor
}

let standard = Palette(
    backgroundTop: color(0x222C40), backgroundBottom: color(0x070A12),
    track: color(0xFFFFFF, 0.10),
    arcStart: color(0x2F5FE0), arcEnd: color(0x8FB0FF),
    needle: color(0xFFFFFF), spark: color(0x8FB0FF)
)

let dark = Palette(
    backgroundTop: color(0x111725), backgroundBottom: color(0x000000),
    track: color(0xFFFFFF, 0.08),
    arcStart: color(0x4A78F0), arcEnd: color(0xA3BEFF),
    needle: color(0xF2F5FF), spark: color(0xA3BEFF)
)

/// iOS colors tinted icons from luminance, so this one is grayscale on black.
let tinted = Palette(
    backgroundTop: color(0x000000), backgroundBottom: color(0x000000),
    track: color(0xFFFFFF, 0.18),
    arcStart: color(0x8C8C8C), arcEnd: color(0xFFFFFF),
    needle: color(0xFFFFFF), spark: color(0xFFFFFF)
)

func draw(_ p: Palette, in ctx: CGContext, size s: CGFloat) {
    let space = CGColorSpace(name: CGColorSpace.sRGB)!

    // Background (CoreGraphics' origin is bottom-left).
    let bg = CGGradient(colorsSpace: space, colors: [p.backgroundTop, p.backgroundBottom] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(bg, start: CGPoint(x: 0, y: s), end: CGPoint(x: 0, y: 0), options: [])

    let center = CGPoint(x: s * 0.5, y: s * 0.39)
    let radius = s * 0.30
    let lineWidth = s * 0.075
    // The gauge sweeps 240°, open at the bottom.
    let startAngle = CGFloat.pi * 7 / 6   // lower left
    let endAngle = -CGFloat.pi / 6        // lower right
    let filledAngle = CGFloat.pi / 4.2    // where the needle points (upper right)

    ctx.setLineCap(.round)
    ctx.setLineWidth(lineWidth)

    // Unfilled track.
    ctx.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    ctx.setStrokeColor(p.track)
    ctx.strokePath()

    // Filled part of the gauge, blue gradient clipped to the stroked arc.
    ctx.saveGState()
    ctx.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: filledAngle, clockwise: true)
    ctx.replacePathWithStrokedPath()
    ctx.clip()
    let arc = CGGradient(colorsSpace: space, colors: [p.arcStart, p.arcEnd] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(
        arc,
        start: CGPoint(x: center.x - radius, y: center.y - radius),
        end: CGPoint(x: center.x + radius, y: center.y + radius),
        options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
    )
    ctx.restoreGState()

    // Needle: a tapered wedge from the hub toward the end of the filled arc.
    let needleLength = radius * 0.78
    let tip = CGPoint(x: center.x + cos(filledAngle) * needleLength, y: center.y + sin(filledAngle) * needleLength)
    let baseHalf = s * 0.028
    let perp = filledAngle + .pi / 2
    ctx.beginPath()
    ctx.move(to: tip)
    ctx.addLine(to: CGPoint(x: center.x + cos(perp) * baseHalf, y: center.y + sin(perp) * baseHalf))
    ctx.addLine(to: CGPoint(x: center.x - cos(perp) * baseHalf, y: center.y - sin(perp) * baseHalf))
    ctx.closePath()
    ctx.setFillColor(p.needle)
    ctx.fillPath()

    // Hub.
    let hub = s * 0.052
    ctx.fillEllipse(in: CGRect(x: center.x - hub, y: center.y - hub, width: hub * 2, height: hub * 2))
    let hubInner = hub * 0.42
    ctx.setFillColor(p.backgroundBottom)
    ctx.fillEllipse(in: CGRect(x: center.x - hubInner, y: center.y - hubInner, width: hubInner * 2, height: hubInner * 2))

    // AI spark: a four-point star above the gauge, with a smaller companion.
    func spark(at c: CGPoint, size r: CGFloat) {
        let waist = r * 0.22
        ctx.beginPath()
        ctx.move(to: CGPoint(x: c.x, y: c.y + r))
        ctx.addQuadCurve(to: CGPoint(x: c.x + r, y: c.y), control: CGPoint(x: c.x + waist, y: c.y + waist))
        ctx.addQuadCurve(to: CGPoint(x: c.x, y: c.y - r), control: CGPoint(x: c.x + waist, y: c.y - waist))
        ctx.addQuadCurve(to: CGPoint(x: c.x - r, y: c.y), control: CGPoint(x: c.x - waist, y: c.y - waist))
        ctx.addQuadCurve(to: CGPoint(x: c.x, y: c.y + r), control: CGPoint(x: c.x - waist, y: c.y + waist))
        ctx.closePath()
        ctx.setFillColor(p.spark)
        ctx.fillPath()
    }
    spark(at: CGPoint(x: s * 0.75, y: s * 0.73), size: s * 0.085)
    spark(at: CGPoint(x: s * 0.87, y: s * 0.62), size: s * 0.04)
}

func render(_ palette: Palette, size: Int, to path: String) {
    let ctx = CGContext(
        data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )!
    draw(palette, in: ctx, size: CGFloat(size))
    let url = URL(fileURLWithPath: path)
    let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(dest) else { fatalError("Could not write \(path)") }
    print("Wrote \(path)")
}

render(standard, size: 1024, to: "\(assets)/AppIcon.appiconset/AppIcon.png")
render(dark, size: 1024, to: "\(assets)/AppIcon.appiconset/AppIcon-Dark.png")
render(tinted, size: 1024, to: "\(assets)/AppIcon.appiconset/AppIcon-Tinted.png")
render(standard, size: 384, to: "\(assets)/AppLogo.imageset/AppLogo.png")
