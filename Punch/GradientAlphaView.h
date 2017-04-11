//
//  GradientAlphaView.h
//  Punch
//
//  Created by 邵晓飞 on 2017/4/10.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface GradientAlphaView : UIView

@property (nonatomic) IBInspectable UIColor *startColor;
@property (nonatomic) IBInspectable UIColor *endColor;

@property (nonatomic) IBInspectable CGPoint startPoint;
@property (nonatomic) IBInspectable CGPoint endPoint;

@end
