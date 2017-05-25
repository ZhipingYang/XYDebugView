//
//  UIColor+XYDebug.m
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "UIColor+XYRandom.h"

@implementation UIColor (XYRandom)

+ (UIColor *)randomLightColorWithAlpha:(CGFloat)alpha
{
    
    return [UIColor colorWithRed:(arc4random()%100+155)/255.0
                           green:(arc4random()%100+155)/255.0
                            blue:(arc4random()%100+155)/255.0
                           alpha:alpha];
}

+ (UIColor *)randomDrakColorWithAlpha:(CGFloat)alpha
{
    
    return [UIColor colorWithRed:(arc4random()%150)/255.0
                           green:(arc4random()%150)/255.0
                            blue:(arc4random()%150)/255.0
                           alpha:alpha];
}
@end
