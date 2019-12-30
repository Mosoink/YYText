//
//  MSTAttributedStringYY.m
//  Teach
//
//  Created by Zhibin on 2019/12/30.
//  Copyright © 2019 XiaoLei. All rights reserved.
//

#import "MSTAttributedStringYY.h"
#import "YYTextLayout.h"
#import "NSAttributedString+YYText.h"
#import <YYWebImage/CALayer+YYWebImage.h>
#import <Ono/Ono.h>

@interface _YYHTMLElement : NSObject

@property (nonatomic, copy) NSDictionary *atts;

- (NSAttributedString *)stringValue;

@end

@implementation _YYHTMLElement

- (NSAttributedString *)stringValue {
    return nil;
}

@end

@interface _YYAttributedText : _YYHTMLElement
{
    NSString *_text;
}
@end

@implementation _YYAttributedText

- (NSAttributedString *)stringValue {
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:_text];
    content.yy_font = [UIFont systemFontOfSize:16];
    content.yy_color = [UIColor blackColor];
    content.yy_lineSpacing = 5;
    return content;
}

- (instancetype)initWith:(NSString *)text {
    self = [super init];
    if (self) {
        _text = text;
    }
    return self;
}

@end

@interface _YYAttributedImage : _YYHTMLElement
{
    NSString *_src;
    CGSize _size;
}
@end

@implementation _YYAttributedImage

- (NSAttributedString *)stringValue {
    NSDictionary *userInfo = @{@"type": @(MSTTextHighlightTypeImage), @"src": _src ?: @""};
    
    CALayer *layer = [CALayer new];
    layer.bounds = CGRectMake(0, 0, _size.width, _size.height);
    NSMutableAttributedString *img = [NSMutableAttributedString yy_attachmentStringWithContent:layer
                                                                                   contentMode:UIViewContentModeScaleAspectFit
                                                                                attachmentSize:layer.bounds.size
                                                                                   alignToFont:[UIFont systemFontOfSize:16]
                                                                                     alignment:YYTextVerticalAlignmentCenter
                                                                                      userInfo:userInfo];
    
    YYTextHighlight *highlight = [YYTextHighlight new];
    highlight.userInfo = userInfo;
    [img yy_setTextHighlight:highlight range:NSMakeRange(0, img.length)];
    return img;
}

- (instancetype)initWith:(NSString *)src width:(CGFloat)width height:(CGFloat)height {
    self = [super init];
    if (self) {
        _src = src;
        _size = CGSizeMake(width, height);
    }
    return self;
}

@end

@interface _YYAttributedAudio : _YYHTMLElement
{
    NSString *_src;
    NSString *_name;
}
@end

@implementation _YYAttributedAudio

- (NSAttributedString *)stringValue {
    NSMutableAttributedString *icon = [NSMutableAttributedString yy_attachmentStringWithContent:[UIImage imageNamed:@"icon_music"]
                                                  contentMode:UIViewContentModeScaleAspectFit
                                               attachmentSize:CGSizeMake(16, 16)
                                                  alignToFont:[UIFont systemFontOfSize:16]
                                                    alignment:YYTextVerticalAlignmentCenter];
    
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:_name];
    name.yy_font = [UIFont systemFontOfSize:16];
    name.yy_color = [UIColor greenColor];
    name.yy_underlineStyle = NSUnderlineStyleSingle;
    name.yy_underlineColor = [UIColor greenColor];
    
    YYTextHighlight *highlight = [YYTextHighlight new];
    highlight.userInfo = @{@"type": @(MSTTextHighlightTypeAudio), @"src": _src ?: @""};
    [name yy_setTextHighlight:highlight range:NSMakeRange(0, name.length)];
    
    NSMutableAttributedString *audio = [NSMutableAttributedString new];
    [audio appendAttributedString:icon];
    [audio yy_appendString:@" "];
    [audio appendAttributedString:name];
    return audio;
}

- (instancetype)initWith:(NSString *)name src:(NSString *)src {
    self = [super init];
    if (self) {
        _src  = src;
        _name = name;
    }
    return self;
}

@end



NSArray<_YYHTMLElement *> *_YYGenHTMLElements(NSString *html) {
    NSMutableArray *array = [NSMutableArray new];
    
    ONOXMLDocument *doc = [ONOXMLDocument HTMLDocumentWithString:html encoding:NSUTF8StringEncoding error:nil];
    
    ONOXMLElement *body = [doc.rootElement.children firstObject];
    for (ONOXMLElement *el in body.children) {
        if ([el.tag isEqualToString:@"p"]) {
            if (el.stringValue.length == 0) {
                continue;
            }
            [array addObject:[[_YYAttributedText alloc] initWith:el.stringValue]];
            continue;
        }
        if ([el.tag isEqualToString:@"img"]) {
            NSString *src = [el valueForAttribute:@"src"];
            CGFloat width = [[el valueForAttribute:@"width"] floatValue];
            CGFloat height = [[el valueForAttribute:@"height"] floatValue];
            [array addObject:[[_YYAttributedImage alloc] initWith:src width:width height:height]];
            continue;
        }
        if ([el.tag isEqualToString:@"audio"]) {
            NSString *src = [el valueForAttribute:@"src"];
            [array addObject:[[_YYAttributedAudio alloc] initWith:el.stringValue src:src]];
            continue;
        }
    }
    
    return array;
}


NSAttributedString *_YYGenContent(NSArray<_YYHTMLElement *> *elements) {
    NSMutableAttributedString *content = [NSMutableAttributedString new];
    for (int i=0; i<elements.count; ++i) {
        _YYHTMLElement *el = elements[i];
        [content appendAttributedString:el.stringValue];
        if (i < elements.count - 1) {
            content.yy_lineSpacing = 0;
            content.yy_paragraphSpacing = 5;
            [content appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    }
    return content;
}


@implementation MSTAttributedStringYY

+ (NSAttributedString *)attributedStringFromHTML:(NSString *)html {
    NSString *_html = @"<p>哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈<p/><img width=\"300px\"  height=\"200px\" src=\"http://img0.imgtn.bdimg.com/it/u=2394972844,3024358326&fm=26&gp=0.jpg\"/><audio src=\"http://localhost/1.mp3\">嚯哈哈</audio>";
    return _YYGenContent(_YYGenHTMLElements(_html));
}

+ (YYTextLayout *)textLayoutFromHTML:(NSString *)html size:(CGSize)size {
    NSAttributedString *text = [self attributedStringFromHTML:html];
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:text];
    return layout;
}

@end
