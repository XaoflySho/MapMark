//
//  GradientAlphaView.m
//  Punch
//
//  Created by 邵晓飞 on 2017/4/10.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import "GradientAlphaView.h"

@interface GradientAlphaView()

@property (nonatomic) CAGradientLayer *gradientLayer;

@end

@implementation GradientAlphaView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self insertTransparentGradient];
        
    }
    
    return self;
}

- (void)insertTransparentGradient {
    
    self.gradientLayer = [CAGradientLayer layer];
    [self.layer addSublayer:self.gradientLayer];
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    _gradientLayer.colors = @[(id)_startColor.CGColor, (id)_endColor.CGColor];
    _gradientLayer.startPoint = _startPoint;
    _gradientLayer.endPoint = _endPoint;
    _gradientLayer.frame = rect;
    
}


@end
