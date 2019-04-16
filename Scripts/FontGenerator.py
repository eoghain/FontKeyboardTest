#!/usr/bin/env python

import sys
import json
import os
import argparse

from textwrap import dedent

def pascalCase(str):
	str = str.replace('-', ' ')
	str = str.replace('_', ' ')
	components = str.split(' ')
	# print components
	# print "".join(x.title() for x in components[0:])
	return "".join(x.title() for x in components[0:])
	
def camelCase(str):
	str = str.replace('-', ' ')
	str = str.replace('_', ' ')
	components = str.split(' ')
	# print components
	# print components[0] + "".join(x.title() for x in components[1:])
	return components[0] + "".join(x.title() for x in components[1:])

def writeFile(fileName, contents):
	header = dedent('''\
	//
	//  %s
	//

	''' % os.path.basename(fileName))

	f = open(fileName, 'w')
	f.write(header)
	f.write(contents)
	f.close()

def createSwift(outputDir, name, prefixText, glyphs):
	outputFileName = outputDir + ('%sIcon.swift' % name)
	writeFile(outputFileName, createSwiftEnum(name, prefixText, glyphs))
	
	outputFileName = outputDir + ('%sIconView.swift' % name)
	writeFile(outputFileName, createSwiftIconView(name))
	
	outputFileName = outputDir + ('%sIconPicker.swift' % name)
	writeFile(outputFileName, createSwiftIconPicker(name))

def createSwiftEnum(name, prefixText, glyphs):
	srcName = ''
	initCases = ''
	cases = ''
	names = ''
	lookupNames = ''

	for glyph in glyphs:
		if (srcName != glyph['src']):
			srcName = glyph['src']

		fontName = glyph['css']
		fullFontName = prefixText + glyph['css']
		hexCode = '\u{%s}' % hex(glyph['code']).replace('0x', '').title()
		lookupName = prefixText + fontName
		
		# Switch and Enum Cases
		cases += 'case %s = "%s"\n\t\t' % (camelCase(fontName), hexCode)
		initCases += 'case "%s", "%s", "%s": self = .%s\n\t\t\t\t' % (fontName, lookupName, hexCode, camelCase(fontName))
		names += 'case .%s: return "%s"\n\t\t\t\t' % (camelCase(fontName), fontName)
		lookupNames += 'case .%s: return "%s"\n\t\t\t\t' % (camelCase(fontName), lookupName) 
		
	swiftFile = dedent('''\
	public enum %(fontName)sIcon: String, CaseIterable {
		%(cases)s
		case missingIcon = "\u{26A0}"
		
		var string: String { return rawValue }
		
		var name: String {
			switch(self) {
				%(names)s
				default: return "missing-icon"
			}
		}
		
		var prefixedName: String {
			switch(self) {
				%(lookupNames)s
				default: return "icon-missing"
			}
		}
		
		static var allCasesButMissing: [%(fontName)sIcon] {
			return allCases.filter { $0 != .missingIcon }
		}
		
		public init(rawValue: String) {
			switch rawValue {
				%(initCases)s
				default: self = .missingIcon
			}
		}
	}''' % ({"fontName": name, "cases": cases.rstrip(), "names": names.rstrip(), "lookupNames": lookupNames.rstrip(), "initCases": initCases.rstrip()}))
	return swiftFile
	
def createSwiftIconView(name):
	swiftFile = dedent('''\
	import UIKit
	import CoreText

	public class %(fontName)sIconView: UIView {

		@IBInspectable public var iconString: String = "" {
			didSet {
				icon = %(fontName)sIcon(rawValue: iconString)
			}
		}
		
		@IBInspectable public var iconColor: UIColor = .darkText {
			didSet {
				setNeedsDisplay()
			}
		}

		public var icon: %(fontName)sIcon? {
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

			let fontDescriptor = CTFontDescriptorCreateWithNameAndSize("%(fontName)s" as CFString, fontSize)
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
	}''' % ({"fontName": name}))
	return swiftFile

def createSwiftIconPicker(name):
	swiftFile = dedent('''\
	import UIKit
	import QuartzCore

	@IBDesignable
	public class %(fontName)sIconPicker: UIControl {

		@IBInspectable var iconString: String = "" {
			didSet {
				icon = %(fontName)sIcon(rawValue: iconString)
			}
		}

		@IBInspectable var iconColor: UIColor = .darkText {
			didSet {
				iconKeyboard.selectionColor = iconColor
				iconView.iconColor = iconColor
				setNeedsDisplay()
			}
		}

		var icon: %(fontName)sIcon? {
			didSet {
				iconView.icon = icon
				setNeedsDisplay()
			}
		}

		private let iconView = %(fontName)sIconView()
		private let textField = UITextField()
		private let iconKeyboard = %(fontName)sIconKeyboard()

		convenience init(icon: %(fontName)sIcon, iconColor: UIColor){
			self.init(frame: .zero)

			self.icon = icon
			self.iconColor = iconColor
		}

		// Default initializer
		override init(frame: CGRect) {
			super.init(frame: frame)
			setup()
		}

		required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
			setup()
		}

		func setup() {
			iconKeyboard.selectionColor = iconColor
			iconKeyboard.delegate = self
			
			addSubview(iconView)
			iconView.isUserInteractionEnabled = false
			iconView.translatesAutoresizingMaskIntoConstraints = false
			iconView.backgroundColor = backgroundColor
			iconView.translatesAutoresizingMaskIntoConstraints = false
			iconView.topAnchor.constraint(equalTo: topAnchor).isActive = true
			iconView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
			iconView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
			iconView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

			addSubview(textField)
			textField.inputView = iconKeyboard.view

			let flexBarButton = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
			let doneBarButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(donePressed(_:)))
			let keyboardToolbar = UIToolbar()
			keyboardToolbar.sizeToFit()
			keyboardToolbar.items = [flexBarButton, doneBarButton]
			textField.inputAccessoryView = keyboardToolbar

			textField.alpha = 0
			textField.translatesAutoresizingMaskIntoConstraints = false
			textField.topAnchor.constraint(equalTo: topAnchor).isActive = true
			textField.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
			textField.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
			textField.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		}

		@objc func donePressed(_ sender: Any) {
			textField.resignFirstResponder()
		}

		override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
			super.touchesBegan(touches, with: event)

			if textField.isFirstResponder {
				textField.resignFirstResponder()
			}
			else {
				textField.becomeFirstResponder()
			}
		}
	}

	extension %(fontName)sIconPicker: %(fontName)sIconKeyboardDelegate {
		func selected(icon: %(fontName)sIcon) {
			self.icon = icon
			self.sendActions(for: UIControl.Event.valueChanged)
		}
	}

	// MARK: - Private internal classes for %(fontName)sIconPicker
	protocol %(fontName)sIconKeyboardDelegate {
		func selected(icon: %(fontName)sIcon)
	}
	
	private class %(fontName)sIconKeyboardCell: UICollectionViewCell {
		var selectionColor: UIColor = .cyan
		var iconView: %(fontName)sIconView = %(fontName)sIconView()
		var icon: %(fontName)sIcon = .missingIcon {
			didSet {
				iconView.icon = icon
			}
		}

		override var isSelected: Bool {
			didSet {
				if isSelected {
					iconView.iconColor = selectionColor
				}
				else {
					iconView.iconColor = .darkText
				}
			}
		}

		override init(frame: CGRect) {
			super.init(frame: frame)
			setup()
		}

		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		override func prepareForReuse() {
			iconView.icon = nil
			isSelected = false
		}

		func setup() {
			backgroundColor = .clear
			contentView.backgroundColor = .white

			// IconView
			iconView.backgroundColor = .white
			contentView.addSubview(iconView)
			iconView.translatesAutoresizingMaskIntoConstraints = false
			iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
			iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
			iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
			iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
		}
	}

	private class %(fontName)sIconKeyboard: UIViewController {

		public var delegate: %(fontName)sIconKeyboardDelegate?
		public var selectionColor: UIColor = .cyan

		private var cellIdentifier = "iconButton"
		private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

		init() {
			super.init(nibName: nil, bundle: nil)
			setup()
		}

		required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
			setup()
		}

		private func setup() {
			view.backgroundColor = .clear

			let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
			layout.estimatedItemSize = CGSize(width: 95, height: 95)
			layout.scrollDirection = .horizontal
			layout.minimumLineSpacing = 10
			layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)

			collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
			collectionView.backgroundColor = .clear
			collectionView.allowsSelection = true
			collectionView.allowsMultipleSelection = false
			collectionView.translatesAutoresizingMaskIntoConstraints = false
			collectionView.register(%(fontName)sIconKeyboardCell.self, forCellWithReuseIdentifier: cellIdentifier)

			view.addSubview(collectionView)
			collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

			collectionView.dataSource = self
			collectionView.delegate = self
		}
	}

	extension %(fontName)sIconKeyboard: UICollectionViewDataSource {
		func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return %(fontName)sIcon.allCasesButMissing.count
		}

		func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! %(fontName)sIconKeyboardCell

			cell.icon = %(fontName)sIcon.allCasesButMissing[indexPath.row]

			// Selection Color
			cell.selectionColor = selectionColor

			// Round & Shadow
			cell.contentView.layer.cornerRadius = 10.0
			cell.contentView.layer.borderWidth = 1.0
			cell.contentView.layer.borderColor = UIColor.clear.cgColor
			cell.contentView.layer.masksToBounds = true

			cell.layer.shadowColor = UIColor.black.cgColor
			cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
			cell.layer.shadowRadius = 2.0
			cell.layer.shadowOpacity = 0.8
			cell.layer.masksToBounds = false
			cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath

			return cell
		}
	}

	extension %(fontName)sIconKeyboard: UICollectionViewDelegate {
		func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
			delegate?.selected(icon: %(fontName)sIcon.allCasesButMissing[indexPath.row])
		}
	}''' % ({"fontName": name}))
	
	return swiftFile


def main(configFile, outputDir):
	try:
		json_data=open(configFile)
	except:
		print "Unable to open %s" % configFile
		exit(1)
		
	data = json.load(json_data)

	name = pascalCase(data['name'])
	glyphs = sorted(data['glyphs'], key=lambda k: k['css']) # sort by name
	glyphs = sorted(glyphs, key=lambda k: k['src']) #sort by name
	prefixText = data['css_prefix_text']
	
	if outputDir[-1] != '/':
		outputDir += '/'
	
	createSwift(outputDir, name, prefixText, glyphs)

def usage(fileName):
	print 'usage: %s [swift] config.json <output directory>' % fileName

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument("configFile", help="config.json file to use")
	parser.add_argument("outputDir", help="outputDirectory")
	args = parser.parse_args()
	
	main(args.configFile, args.outputDir)
