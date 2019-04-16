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
	outputFileName = outputDir + ('%sIcons.swift' % name)
	writeFile(outputFileName, createSwiftCategory(name, prefixText, glyphs))
	outputFileName = outputDir + ('%sIcon.swift' % name)
	writeFile(outputFileName, createSwiftEnum(name, prefixText, glyphs))
	outputFileName = outputDir + ('%sIconView.swift' % name)
	writeFile(outputFileName, createSwiftIconView(name))

def createSwiftCategory(name, prefixText, glyphs):
	className = '%sIcons' % name
	swiftFile = dedent('''\
	public struct %s {
	''' % (className))
	
	srcName = ''
	lookups = ''

	for glyph in glyphs:
		if (srcName != glyph['src']):
			srcName = glyph['src']

		fontName = glyph['css']
		fullFontName = prefixText + glyph['css']
		swiftFile += '\tpublic static let %s = "\u{%s}"\n' % (camelCase(fontName), hex(glyph['code']).replace('0x', '').title())
		
		lookupName = prefixText + fontName
		lookups += 'case "%s", "%s":\n\t\t\t\t\treturn %s.%s\n\t\t\t\t' % (fontName, lookupName, className, camelCase(fontName))
		
	swiftFile += ('\n\tpublic static func iconNamed(name: String) -> String {\n\t\tswitch(name) {\n')
		
	swiftFile += dedent('''\
				%sdefault:
					return "\u{26A0}"
			}
		}
	}''' % (lookups))
	return swiftFile

def createSwiftEnum(name, prefixText, glyphs):
	className = '%sIcon' % name
	swiftFile = dedent('''\
	public enum %s: String, CaseIterable {
	''' % (className))
	
	srcName = ''
	initCases = ''
	cases = ''
	fontNames = ''
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
		fontNames += 'case .%s: return "%s"\n\t\t\t\t' % (camelCase(fontName), fontName)
		lookupNames += 'case .%s: return "%s"\n\t\t\t\t' % (camelCase(fontName), lookupName) 
		
	swiftFile = dedent('''\
	public enum %s: String, CaseIterable {
		%s
		case missingIcon = "\u{26A0}"
		
		var string: String { return rawValue }
		
		var name: String {
			switch(self) {
				%s
				default: return "missing-icon"
			}
		}
		
		var prefixedName: String {
			switch(self) {
				%s
				default: return "icon-missing"
			}
		}
		
		static var allCasesButMissing: [%s] {
			return allCases.filter { $0 != .missingIcon }
		}
		
		public init(rawValue: String) {
			switch rawValue {
				%s
				default: self = .missingIcon
			}
		}
	}''' % (className, cases.rstrip(), fontNames.rstrip(), lookupNames.rstrip(), className, initCases.rstrip()))
	return swiftFile
	
def createSwiftIconView(name):
	className = "%sIconView" % name
	iconFontName = "%sIcon" % name
	swiftFile = dedent('''\
	import UIKit
	import CoreText

	public class %s: UIView {

		@IBInspectable public var iconString: String = "" {
			didSet {
				icon = %s(rawValue: iconString)
			}
		}
		
		@IBInspectable public var iconColor: UIColor = .darkText {
			didSet {
				setNeedsDisplay()
			}
		}

		public var icon: %s? {
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

			let fontDescriptor = CTFontDescriptorCreateWithNameAndSize("%s" as CFString, fontSize)
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
	}''' % (className, iconFontName, iconFontName, name))
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
