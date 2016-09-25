//
//  YcDrawRectView.m
//  GbssApps-IOS
//
//  Created by Suycity on 15/8/14.
//
//

#import "DrawRectView.h"

@implementation DrawRectView{
    CGPoint *_points;
    CGRect *_rects;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)dealloc{
    if(_points)free(_points);
    if(_rects)free(_rects);
}
- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGFloat lineWidth = 3;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineWidth);
    
    // test draw background
//    CGContextAddRect(context,self.bounds);
//    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
//    CGContextFillPath(context);
    
    // draw rect
    CGContextAddRect(context,_rects[0]);
    CGContextAddRect(context,_rects[1]);
    CGContextAddRect(context,_rects[2]);
    CGContextAddRect(context,_rects[3]);
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] colorWithAlphaComponent:.6].CGColor);
    CGContextFillPath(context);
    
    // draw line
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextMoveToPoint(context, _points[0].x - lineWidth/2, _points[0].y - lineWidth/2);
    CGContextAddLineToPoint(context, _points[1].x, _points[1].y);
    CGContextAddLineToPoint(context, _points[2].x, _points[2].y);
    CGContextAddLineToPoint(context, _points[3].x, _points[3].y);
    CGContextAddLineToPoint(context, _points[0].x, _points[0].y);
    CGContextStrokePath(context);
}
- (void)drawSize:(CGSize)size{
    [self drawFrame:(CGRect){
        (CGRectGetWidth(self.frame) - size.width)/2,
        (CGRectGetHeight(self.frame) - size.width)/2,
        size
    }];
}
- (CGRect)getDrawFrame{
    if (_points) {
        return (CGRect){
            _points[0],
            _points[2].x - _points[0].x,
            _points[2].y - _points[0].y};
    }
    return CGRectZero;
}
- (void)drawFrame:(CGRect)frame{
    [self setBackgroundColor:[UIColor clearColor]];
    if(!_points)_points = malloc(sizeof(CGPoint) * 4);
    _points[0] = (CGPoint){CGRectGetMinX(frame),CGRectGetMinY(frame)};
    _points[1] = (CGPoint){CGRectGetMaxX(frame),CGRectGetMinY(frame)};
    _points[2] = (CGPoint){CGRectGetMaxX(frame),CGRectGetMaxY(frame)};
    _points[3] = (CGPoint){CGRectGetMinX(frame),CGRectGetMaxY(frame)};
    
    if (!_rects)_rects = malloc(sizeof(CGRect) * 4);
    // 上半部分
    _rects[0] = (CGRect){0,0,CGRectGetWidth(self.frame),CGRectGetMinY(frame)};
    
    //两侧部分
    _rects[1] = (CGRect){0,CGRectGetMinY(frame),CGRectGetMinX(frame),CGRectGetHeight(frame)};
    _rects[2] = (CGRect){
        CGRectGetMaxX(frame),
        CGRectGetMinY(frame),
        CGRectGetWidth(self.frame) - CGRectGetMaxX(frame),
        CGRectGetHeight(frame)};
    //下半部分
    _rects[3] = (CGRect){
        0,CGRectGetMaxY(frame),
        CGRectGetWidth(self.frame),
        CGRectGetHeight(self.frame) - CGRectGetMaxY(frame)};
    
    [self setNeedsDisplay];
}
@end
