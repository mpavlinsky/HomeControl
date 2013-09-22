//
//  HCSimpleEmojiIcon.m
//  HomeControl
//
//  Created by Matthew Pavlinsky on 9/22/13.
//  Copyright (c) 2013 Matthew Pavlinsky. All rights reserved.
//

#import "HCSimpleEmojiIcon.h"

@implementation HCSimpleEmojiIcon

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frameSize = CGSizeMake(200.0f, 200.0f);
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

+ (HCSimpleEmojiIcon*)iconWithText:(NSString*)text andSize:(CGFloat)size {
    HCSimpleEmojiIcon* newIcon = [[HCSimpleEmojiIcon alloc] init];
    if (newIcon) {
        newIcon.text = text;
        newIcon.font = [UIFont systemFontOfSize:size];
    }
    
    return newIcon;
}

@end
