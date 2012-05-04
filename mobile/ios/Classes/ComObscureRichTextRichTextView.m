//
//  ComObscureRichTextRichTextView.m
//  richtext
//
//  Created by Paul Mietz Egli on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ComObscureRichTextRichTextView.h"
#import "TiViewProxy.h"
#import "DTCoreText.h"

// as per http://www.cocoanetics.com/2011/08/nsattributedstringhtml-qa/
#define kDefaultFontSize 12.0 

@interface ComObscureRichTextRichTextView (PrivateMethods)
//- (DTAttributedTextView *)attributedTextView;
- (void)setAttributedTextViewContent;
@end

@implementation ComObscureRichTextRichTextView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        options = [[NSMutableDictionary dictionary] retain];
        configSet = NO;

        attributedTextView = [[DTAttributedTextView alloc] initWithFrame:[self bounds]];
        attributedTextView.autoresizesSubviews = YES;
        [self addSubview:attributedTextView];
    }
    return self;
}

- (void)dealloc {
    RELEASE_TO_NIL(attributedTextView)
    RELEASE_TO_NIL(content)
    RELEASE_TO_NIL(options)
    [super dealloc];
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds {
    [super frameSizeChanged:frame bounds:bounds];
    // calling setBounds on attributed 
    [attributedTextView setFrame:bounds];
}

#pragma mark -
#pragma mark TiUIView

- (void)configurationSet {
    [super configurationSet];
    configSet = YES;
    [self setAttributedTextViewContent];
}

-(CGFloat)contentHeightForWidth:(CGFloat)value {
    return [attributedTextView.contentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:value].height;
}

- (CGFloat)verifyHeight:(CGFloat)suggestedHeight {
    CGFloat width = attributedTextView.frame.size.width;
    return [attributedTextView.contentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:width].height;
}

- (void)setBackgroundColor_:(id)val {
    UIColor * color = [TiUtils colorValue:val].color;
    attributedTextView.backgroundColor = color;
}

- (void)setColor_:(id)val {
    UIColor * color = [TiUtils colorValue:val].color;    
    [options setValue:color forKey:DTDefaultTextColor];
    [self setAttributedTextViewContent];
}

- (void)setFont_:(id)val {
    WebFont * font = [TiUtils fontValue:val];
    [options setValue:font.font.familyName forKey:DTDefaultFontFamily];
    [options setValue:[NSNumber numberWithFloat:(font.size / kDefaultFontSize)] forKey:NSTextSizeMultiplierDocumentOption];
    [self setAttributedTextViewContent];
}


#pragma mark -
#pragma mark DTAttributedTextView

- (void)setAttributedTextViewContent {
    if (!configSet) return; // lazy init
    
    NSAttributedString * str = nil;

    switch (contentType) {
        case kContentTypeHTML:
            str = [[NSAttributedString alloc] initWithHTML:[content dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil];
            break;
        default:
            str = [[NSAttributedString alloc] initWithString:content];
            break;
    }

    if (str) {
        attributedTextView.attributedString = str;
        NSLog(@"set text content");
    }
}

- (void)setText_:(id)text {
    ENSURE_STRING_OR_NIL(text)
    RELEASE_TO_NIL(content)
    contentType = kContentTypeText;
    content = [text retain];
    [self setAttributedTextViewContent];
}

- (void)setHtml_:(id)html {
    ENSURE_STRING_OR_NIL(html)
    RELEASE_TO_NIL(content)
    contentType = kContentTypeHTML;
    content = [html retain];
    [self setAttributedTextViewContent];
}

// TODO setMarkdown_ ?

@end
