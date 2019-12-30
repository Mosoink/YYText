//
//  MSTAttributedStringYY.h
//  Teach
//
//  Created by Zhibin on 2019/12/30.
//  Copyright © 2019 XiaoLei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSUInteger, MSTTextHighlightType) {
    MSTTextHighlightTypeImage,
    MSTTextHighlightTypeAudio
};

@class YYTextLayout;
@interface MSTAttributedStringYY : NSObject

+ (YYTextLayout *)textLayoutFromHTML:(NSString *)html size:(CGSize)size;

@end
