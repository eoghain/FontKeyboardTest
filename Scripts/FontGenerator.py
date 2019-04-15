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

def createCategoryHeader(name, prefixText, glyphs):
	hFile = '#import <Foundation/Foundation.h>\n\n@interface NSString (%s)\n' % name
	srcName = ''

	for glyph in glyphs:
		if (srcName != glyph['src']):
			srcName = glyph['src']
			hFile += '\n// %s Strings\n' % srcName

		fontName = prefixText + glyph['css']
		hFile += '+ (NSString *)%s;\n' % camelCase(fontName)
	
	hFile += '\n// Helper Methods\n'
	hFile += '+ (NSString *)iconForName:(NSString *)iconName;\n'

	hFile += '\n\n@end'
	return hFile

def createCategoryCode(name, prefixText, glyphs):
	mFile = dedent('''\
	#import "%s"
	
	static NSDictionary *iconLookupTable;
	
	@implementation NSString (%s)
	''' % (('NSString+%s.h' % name), name))
	
	srcName = ''
	lookupTable = ''
	lookups = ''
	index = 0

	for glyph in glyphs:
		if (srcName != glyph['src']):
			srcName = glyph['src']
			mFile += '\n#pragma mark - %s\n\n' % srcName

		fontName = prefixText + glyph['css']
		mFile += dedent('''\
		+ (NSString *)%s
		{
			return @"%s";
		}
		''') % (camelCase(fontName), '\u' + hex(glyph['code']).replace('0x', '').title())
		
		# lookupTable += '@"%s" : @( %d ),\n\t\t\t' % (glyph['css'], index)
		# lookupTable += '@"%s" : @( %d ),\n\t\t\t' % (fontName, index)
		# lookups += 'case %d:\n\t\t\treturn [self %s];\n\t\t\tbreak;\n\t\t' % (index, camelCase(fontName))
		# lookups += '@"%s" : ^NSString*(){ return [self %s]; },\n\t\t\t' % (glyph['css'], camelCase(fontName))
		# lookups += '@"%s" : ^NSString*(){ return [self %s]; },\n\t\t\t' % (fontName, camelCase(fontName))
		index += 1

	mFile += dedent('''
	#pragma mark - Helper Methods
	
	+ (NSString *)iconForName:(NSString *)iconName
	{
		if ([iconName containsString:@"-"])
		{
			NSArray *parts = [iconName componentsSeparatedByString:@"-"];
			NSMutableArray *fixedParts = [NSMutableArray arrayWithCapacity:parts.count];

			[parts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				if ([obj isEqualToString:@"icon"] == NO)
				{
					if (idx == 0)
					{
						[fixedParts addObject:@"icon"];
					}
					obj = [obj capitalizedString];
				}
				
				[fixedParts addObject:obj];
			}];
			
			iconName = [fixedParts componentsJoinedByString:@""];
		}
		else if ([iconName containsString:@"icon"] == NO)
		{
			iconName = [NSString stringWithFormat:@"icon%@", [iconName capitalizedString]];
		}

		// Convoluted way to call perform selector to prevent warning 'performSelector may cause a leak because its selector is unknown'
		// http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
		SEL selector = NSSelectorFromString(iconName);
		if ([self respondsToSelector:selector])
		{
			IMP imp = [self methodForSelector:selector];
			NSString* (*func)(id, SEL) = (void *)imp;
			return func(self, selector);
		}
		else
		{
			return  @"\u26A0";
		}
	}
	@end''') 
	
	# mFile += '@end'
	return mFile

def createIconViewHeader(name):
	className = "%sIconView" % name

	hFile = dedent(''' 
		#import <UIKit/UIKit.h>

		IB_DESIGNABLE
		@interface %s : UIView

		@property (strong, nonatomic) IBInspectable NSString * icon;
		@property (strong, nonatomic) IBInspectable UIColor * fontColor;

		@end"''' % className)
	return hFile;

def createIconViewCode(name):
	className = "%sIconView" % name
	mFile = dedent('''\
		#import "%s.h"
		#import <CoreText/CoreText.h>

		@implementation %s

		- (void)drawRect:(CGRect)rect
		{
			[super drawRect:rect];

			CGFloat fontSize = MIN(rect.size.width, rect.size.height) / 2;
			CFStringRef string; CTFontRef font; CGContextRef context;

			// Initialize the string, font, and context
			string = (__bridge CFStringRef)self.icon;
			CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithNameAndSize((CFStringRef)@"%s", fontSize);
			font = CTFontCreateWithFontDescriptor(fontDescriptor, fontSize, NULL);
			context = UIGraphicsGetCurrentContext();

			CGContextSetTextMatrix(context, CGAffineTransformIdentity);
			CGContextTranslateCTM(context, 0, self.bounds.size.height);
			CGContextScaleCTM(context, 1.0, -1.0);

			CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
			CFTypeRef values[] = { font, self.fontColor.CGColor };

			CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
			(const void**)&values, sizeof(keys) / sizeof(keys[0]),
			&kCFTypeDictionaryKeyCallBacks,
			&kCFTypeDictionaryValueCallBacks);

			CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
			CFRelease(string);
			CFRelease(attributes);

			CTLineRef line = CTLineCreateWithAttributedString(attrString);

			CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
			CFRange range;
			CGSize constraint = rect.size;
			CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 1), nil, constraint, &range);

			// Set text position and draw the line into the graphics context
			CGContextSetTextPosition(context, (rect.size.width - coreTextSize.width) / 2, (rect.size.height - coreTextSize.height) / 2);
			CTLineDraw(line, context);
			CFRelease(line);
		}

		@end''' % (className, className, name))
	return mFile;

def createSwift(outputDir, name, prefixText, glyphs):
	outputFileName = outputDir + ('%sIcons.swift' % name)
	writeFile(outputFileName, createSwiftCategory(name, prefixText, glyphs))
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

def createSwiftIconView(name):
	className = "%sIconView" % name
	swiftFile = dedent('''\
	import UIKit
	import CoreText

	public class %s: UIView {

		@IBInspectable public var icon: String = ""
		@IBInspectable public var fontColor: UIColor = .darkText

		override public func draw(_ rect: CGRect) {
			super.draw(rect)

			// Initialize the context
			guard let context = UIGraphicsGetCurrentContext() else { return }

			context.textMatrix = .identity
			context.translateBy(x: 0, y: bounds.size.height)
			context.scaleBy(x: 1, y: -1)
	
			// Initialize the string and font
			let fontSize: CGFloat = min(rect.size.width, rect.size.height) / 2

			let string = self.icon as CFString
			let fontDescriptor = CTFontDescriptorCreateWithNameAndSize("%s" as CFString, fontSize)
			let font = CTFontCreateWithFontDescriptor(fontDescriptor, fontSize, nil)

			let attributes = [
				kCTFontAttributeName : font,
				kCTForegroundColorAttributeName : fontColor.cgColor
			] as CFDictionary

			// Build the font string
			guard let attrString = CFAttributedStringCreate(kCFAllocatorDefault, string, attributes) else { return }

			let line = CTLineCreateWithAttributedString(attrString)

			let framesetter = CTFramesetterCreateWithAttributedString(attrString)
			var range: CFRange = CFRange()
			let constraints = rect.size
			let coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,1), nil, constraints, &range)

			// Set text position and draw the line into the graphics context
			context.textPosition = CGPoint(x: (rect.size.width - coreTextSize.width) / 2, y: (rect.size.height - coreTextSize.height) / 2)
			CTLineDraw(line, context)
		}
	}''' % (className, name))
	return swiftFile

def main(configFile, outputDir, generateSwift):
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
	
	if generateSwift:
		createSwift(outputDir, name, prefixText, glyphs)
		# outputFileName = outputDir + ('%sIcons.swift' % name)
		# writeFile(outputFileName, createSwift(name, prefixText, glyphs))
	else:
		outputFileName = outputDir + ('NSString+%s.h' % name)
		writeFile(outputFileName, createCategoryHeader(name, prefixText, glyphs))

		outputFileName = outputDir + ('NSString+%s.m' % name)
		writeFile(outputFileName, createCategoryCode(name, prefixText, glyphs))
	
		outputFileName = outputDir + ('%sIconView.h' % name)
		writeFile(outputFileName, createIconViewHeader(name))

		outputFileName = outputDir + ('%sIconView.m' % name)
		writeFile(outputFileName, createIconViewCode(name))

def usage(fileName):
	print 'usage: %s [swift] config.json <output directory>' % fileName

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument("-s", "--swift", help="Set if you want swift output", action="store_true")
	parser.add_argument("configFile", help="config.json file to use")
	parser.add_argument("outputDir", help="outputDirectory")
	args = parser.parse_args()
	
	main(args.configFile, args.outputDir, args.swift)
