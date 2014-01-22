//
//  UIColor+BusLinesColor.m
//  FastBusBCN
//
//  Created by Natxo Raga on 20/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import "UIColor+BusLinesColor.h"


// TODO: FINISH IMPLEMENTATION
@implementation UIColor (BusLinesColor)

#pragma mark - Barcelona city

+ (UIColor *)defaultBusLineColor
{
    return [UIColor colorWithRed:220.0/255.0 green:50.0/255.0 blue:45.0/255.0 alpha:1.0];
}

+ (UIColor *)baixBusLineColor
{
    return [UIColor colorWithRed:250.0/255.0 green:182.0/255.0 blue:20.0/255.0 alpha:1.0];
}

+ (UIColor *)nitBusLineColor
{
    return [UIColor colorWithRed:0.0/255.0 green:90.0/255.0 blue:195.0/255.0 alpha:1.0];
}

+ (UIColor *)aeroBusLineColor {return nil;}

+ (UIColor *)ciutatjusticiaBusLineColor {return nil;}

+ (UIColor *)turisticBusLineColor {return nil;}

#pragma mark - New Barcelona city lines

+ (UIColor *)vBusLineColor
{
    return [UIColor colorWithRed:115.0/255.0 green:180.0/255.0 blue:50.0/255.0 alpha:1.0];
}

+ (UIColor *)hBusLineColor
{
    return [UIColor colorWithRed:20.0/255.0 green:70.0/255.0 blue:145.0/255.0 alpha:1.0];
}

+ (UIColor *)dBusLineColor
{
    return [UIColor colorWithRed:154.0/255.0 green:35.0/255.0 blue:135.0/255.0 alpha:1.0];
}

#pragma mark - Barcelona suburbs

+ (UIColor *)badalonaBusLineColor {return nil;}

+ (UIColor *)castelldefelsBusLineColor {return nil;}

+ (UIColor *)espluguesBusLineColor {return nil;}

+ (UIColor *)gavaBusLineColor {return nil;}

+ (UIColor *)santjustesvernBusLineColor {return nil;}

+ (UIColor *)hospitaletBusLineColor {return nil;}

+ (UIColor *)pratBusLineColor {return nil;}

+ (UIColor *)santboiBusLineColor {return nil;}

+ (UIColor *)santfeliuBusLineColor {return nil;}

+ (UIColor *)viladecansBusLineColor {return nil;}

@end
