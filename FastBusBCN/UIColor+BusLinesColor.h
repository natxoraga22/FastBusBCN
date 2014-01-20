//
//  UIColor+BusLinesColor.h
//  FastBusBCN
//
//  Created by Natxo Raga on 20/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (BusLinesColor)

#pragma mark - Barcelona city

+ (UIColor *)defaultBusLineColor;
+ (UIColor *)baixBusLineColor;
+ (UIColor *)nitBusLineColor;
+ (UIColor *)aeroBusLineColor;
+ (UIColor *)ciutatjusticiaBusLineColor;
+ (UIColor *)turisticBusLineColor;

#pragma mark - New Barcelona city lines

+ (UIColor *)vBusLineColor;
+ (UIColor *)hBusLineColor;
+ (UIColor *)dBusLineColor;

#pragma mark - Barcelona suburbs

+ (UIColor *)badalonaBusLineColor;
+ (UIColor *)castelldefelsBusLineColor;
+ (UIColor *)espluguesBusLineColor;
+ (UIColor *)gavaBusLineColor;
+ (UIColor *)santjustesvernBusLineColor;
+ (UIColor *)hospitaletBusLineColor;
+ (UIColor *)pratBusLineColor;
+ (UIColor *)santboiBusLineColor;
+ (UIColor *)santfeliuBusLineColor;
+ (UIColor *)viladecansBusLineColor;

@end
