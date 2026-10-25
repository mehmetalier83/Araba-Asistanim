// Renders the app icon ("Konuşan Araç": a friendly car face with an AI spark)
// as opaque 1024×1024 PNGs for the AppIcon set, plus the transparent in-app
// mark (car face and spark only) used on the Welcome screen.
//
//   swift Config/AppIcon/render_icon.swift
//
// Run from the repository root; it overwrites the PNGs in Assets.xcassets.
// Coordinates below are on a 1024×1024 canvas with y pointing down.

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let assets = "Araba Asistanim/Assets.xcassets"
let canvas: CGFloat = 1024
let space = CGColorSpace(name: CGColorSpace.sRGB)!

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha
    )
}

struct Variant {
    /// Background gradient, top-left → bottom-right. `nil` leaves it transparent.
    var background: (CGColor, CGColor)?
    var highlight: Bool
    /// Fill for the eyes, smile and windshield.
    var feature: (CGColor, CGColor)
    var shape: CGColor
}

let brand = (color(0x5B6CFF), color(0xA65CFF))

let standard = Variant(background: brand, highlight: true, feature: brand, shape: color(0xFFFFFF))
let dark = Variant(background: (color(0x1D1A46), color(0x100E28)), highlight: false, feature: brand, shape: color(0xFFFFFF))
/// iOS colors tinted icons from luminance, so this one is grayscale on black.
let tinted = Variant(background: (color(0x000000), color(0x000000)), highlight: false, feature: (color(0x000000), color(0x000000)), shape: color(0xFFFFFF))
let mark = Variant(background: nil, highlight: false, feature: brand, shape: color(0xFFFFFF))

// MARK: - Shapes

func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

let body: CGPath = {
    let path = CGMutablePath()
    path.move(to: p(250, 560))
    path.addLine(to: p(300, 380))
    path.addQuadCurve(to: p(380, 320), control: p(318, 320))
    path.addLine(to: p(644, 320))
    path.addQuadCurve(to: p(724, 380), control: p(706, 320))
    path.addLine(to: p(774, 560))
    path.addQuadCurve(to: p(820, 630), control: p(820, 580))
    path.addLine(to: p(820, 740))
    path.addQuadCurve(to: p(790, 770), control: p(820, 770))
    path.addLine(to: p(234, 770))
    path.addQuadCurve(to: p(204, 740), control: p(204, 770))
    path.addLine(to: p(204, 630))
    path.addQuadCurve(to: p(250, 560), control: p(204, 580))
    path.closeSubpath()
    return path
}()

let tyres: CGPath = {
    let path = CGMutablePath()
    for x: CGFloat in [250, 664] {
        path.addRoundedRect(in: CGRect(x: x, y: 770, width: 110, height: 70), cornerWidth: 26, cornerHeight: 26)
    }
    return path
}()

let windshield: CGPath = {
    let path = CGMutablePath()
    path.move(to: p(330, 540))
    path.addLine(to: p(362, 410))
    path.addQuadCurve(to: p(400, 380), control: p(370, 380))
    path.addLine(to: p(624, 380))
    path.addQuadCurve(to: p(662, 410), control: p(654, 380))
    path.addLine(to: p(694, 540))
    path.closeSubpath()
    return path
}()

func circles(_ centers: [CGPoint], radius r: CGFloat) -> CGPath {
    let path = CGMutablePath()
    for c in centers {
        path.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
    }
    return path
}

let eyes = circles([p(330, 640), p(694, 640)], radius: 54)
let eyeHighlights = circles([p(346, 624), p(710, 624)], radius: 16)

let smile: CGPath = {
    let path = CGMutablePath()
    path.move(to: p(440, 680))
    path.addQuadCurve(to: p(584, 680), control: p(512, 735))
    return path.copy(strokingWithWidth: 30, lineCap: .round, lineJoin: .round, miterLimit: 10)
}()

let sparkle: CGPath = {
    let path = CGMutablePath()
    path.move(to: p(512, 150))
    path.addCurve(to: p(588, 226), control1: p(521, 200), control2: p(538, 217))
    path.addCurve(to: p(512, 302), control1: p(538, 235), control2: p(521, 252))
    path.addCurve(to: p(436, 226), control1: p(503, 252), control2: p(486, 235))
    path.addCurve(to: p(512, 150), control1: p(486, 217), control2: p(503, 200))
    path.closeSubpath()
    return path
}()

// MARK: - Drawing

func fillGradient(_ colors: (CGColor, CGColor), clippedTo path: CGPath?, alpha: CGFloat = 1, in ctx: CGContext) {
    ctx.saveGState()
    if let path {
        ctx.addPath(path)
        ctx.clip()
    }
    ctx.setAlpha(alpha)
    let gradient = CGGradient(colorsSpace: space, colors: [colors.0, colors.1] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(gradient, start: .zero, end: p(canvas, canvas), options: [])
    ctx.restoreGState()
}

func fill(_ path: CGPath, _ color: CGColor, in ctx: CGContext) {
    ctx.addPath(path)
    ctx.setFillColor(color)
    ctx.fillPath()
}

func draw(_ v: Variant, in ctx: CGContext) {
    if let background = v.background {
        fillGradient(background, clippedTo: nil, in: ctx)
    }
    if v.highlight {
        let glow = CGGradient(colorsSpace: space, colors: [color(0xFFFFFF, 0.3), color(0xFFFFFF, 0)] as CFArray, locations: [0, 1])!
        ctx.drawRadialGradient(glow, startCenter: p(256, 205), startRadius: 0, endCenter: p(256, 205), endRadius: 920, options: [])
    }

    fill(body, v.shape, in: ctx)
    fill(tyres, v.shape, in: ctx)
    fillGradient(v.feature, clippedTo: windshield, alpha: 0.18, in: ctx)
    fillGradient(v.feature, clippedTo: eyes, in: ctx)
    fill(eyeHighlights, v.shape, in: ctx)
    fillGradient(v.feature, clippedTo: smile, in: ctx)
    fill(sparkle, v.shape, in: ctx)
}

/// Draws `variant` on the 1024 canvas (y down) and writes the part inside
/// `crop` scaled to `size`×`size` pixels.
func render(_ variant: Variant, size: Int, crop: CGRect = CGRect(x: 0, y: 0, width: canvas, height: canvas), to path: String) {
    let opaque = variant.background != nil
    let ctx = CGContext(
        data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0, space: space,
        bitmapInfo: (opaque ? CGImageAlphaInfo.noneSkipLast : CGImageAlphaInfo.premultipliedLast).rawValue
    )!
    let scale = CGFloat(size) / crop.width
    ctx.translateBy(x: 0, y: CGFloat(size))
    ctx.scaleBy(x: scale, y: -scale)
    ctx.translateBy(x: -crop.minX, y: -crop.minY)
    draw(variant, in: ctx)

    let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(dest) else { fatalError("Could not write \(path)") }
    print("Wrote \(path)")
}

render(standard, size: 1024, to: "\(assets)/AppIcon.appiconset/AppIcon.png")
render(dark, size: 1024, to: "\(assets)/AppIcon.appiconset/AppIcon-Dark.png")
render(tinted, size: 1024, to: "\(assets)/AppIcon.appiconset/AppIcon-Tinted.png")
// The mark spans x 204…820, y 150…840; a centered square around it.
render(mark, size: 384, crop: CGRect(x: 167, y: 150, width: 690, height: 690), to: "\(assets)/AppLogo.imageset/AppLogo.png")
