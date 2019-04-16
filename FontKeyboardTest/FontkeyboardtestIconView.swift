//
//  FontkeyboardtestIconView.swift
//

import UIKit
import CoreText

public class FontkeyboardtestIconView: UIView {

	@IBInspectable public var iconString: String = "" {
		didSet {
			icon = FontkeyboardtestIcon(rawValue: iconString)
		}
	}

	@IBInspectable public var iconColor: UIColor = .darkText {
		didSet {
			setNeedsDisplay()
		}
	}

	public var icon: FontkeyboardtestIcon? {
		didSet {
			setNeedsDisplay()
		}
	}

	override public func draw(_ rect: CGRect) {
		super.draw(rect)
		guard let icon = self.icon else { return }

		// Initialize the context
		guard let context = UIGraphicsGetCurrentContext() else { return }

		context.textMatrix = .identity
		context.translateBy(x: 0, y: bounds.size.height)
		context.scaleBy(x: 1, y: -1)

		// Initialize the string and font
		let fontSize: CGFloat = min(rect.size.width, rect.size.height) / 2

		let fontDescriptor = CTFontDescriptorCreateWithNameAndSize("Fontkeyboardtest" as CFString, fontSize)
		let font = CTFontCreateWithFontDescriptor(fontDescriptor, fontSize, nil)

		let attributes = [
			kCTFontAttributeName : font,
			kCTForegroundColorAttributeName : iconColor.cgColor
		] as CFDictionary

		// Build the font string
		let cfString = icon.string as CFString
		guard let attrString = CFAttributedStringCreate(kCFAllocatorDefault, cfString, attributes) else { return }

		let line = CTLineCreateWithAttributedString(attrString)

		let framesetter = CTFramesetterCreateWithAttributedString(attrString)
		var range: CFRange = CFRange()
		let constraints = rect.size
		let coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,1), nil, constraints, &range)

		// Set text position and draw the line into the graphics context
		context.textPosition = CGPoint(x: (rect.size.width - coreTextSize.width) / 2, y: (rect.size.height - coreTextSize.height) / 2)
		CTLineDraw(line, context)
	}
}