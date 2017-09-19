//
//  NirKxMenu.m
//  NirKxMenu
//
//  Created by Nirvana on 9/25/15.
//  Copyright © 2015 NSNirvana. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KxMenuItem : NSObject

@property (readwrite, nonatomic, strong) UIImage *image;
@property (readwrite, nonatomic, strong) NSString *title;
@property (readwrite, nonatomic, weak) id target;
@property (readwrite, nonatomic) SEL action;
@property (readwrite, nonatomic, strong) UIColor *foreColor;
@property (readwrite, nonatomic) NSTextAlignment alignment;

+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                   target:(id)target
                   action:(SEL) action;

@end

typedef struct{
    CGFloat R;
    CGFloat G;
    CGFloat B;

}Color;

typedef struct {
    CGFloat arrowSize;             //箭头大小
    CGFloat marginXSpacing;        //X间距
    CGFloat marginYSpacing;        //Y间距
    CGFloat intervalSpacing;       //间距
    CGFloat menuCornerRadius;      //菜单圆角半径
    Boolean maskToBackground;      //屏蔽背景
    Boolean shadowOfMenu;          //菜单有阴影
    Boolean hasSeperatorLine;      //有分离线
    Boolean seperatorLineHasInsets;//分离线有插图
    Color textColor;               //字体颜色
    Color menuBackgroundColor;     //背景颜色
    
}OptionalConfiguration;


@interface KxMenuView : UIView

@property (atomic, assign) OptionalConfiguration kxMenuViewOptions;

@end

@interface KxMenu : NSObject

+ (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems
                withOptions:(OptionalConfiguration) options;

+ (void) dismissMenu;

+ (UIColor *) tintColor;
+ (void) setTintColor: (UIColor *) tintColor;

+ (UIFont *) titleFont;
+ (void) setTitleFont: (UIFont *) titleFont;

@end
