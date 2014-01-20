//
//  NextBusTableViewCell.h
//  FastBusBCN
//
//  Created by Natxo Raga on 19/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NextBusTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nextBusLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextBusTimeLabel;
@end
