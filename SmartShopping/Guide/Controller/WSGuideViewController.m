//
//  WSGuideViewController.m
//  SmartShopping
//
//  Created by wrs on 15/5/29.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSGuideViewController.h"

@interface WSGuideViewController () <UIScrollViewDelegate>

@property (assign, nonatomic) NSInteger imageCount;
@property (assign, nonatomic) NSInteger curIndex;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewWithCon;

@end

@implementation WSGuideViewController
@synthesize imageCount, curIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    curIndex = 0;
    imageCount = _imageArray.count;
    _containerViewWithCon.constant = SCREEN_WIDTH * imageCount;
    
    
    for (int i = 0; i < imageCount; i++) {
        NSString *imageName  = [_imageArray objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", imageName]];
        switch (i) {
            case 0:
                imageView.backgroundColor = [UIColor yellowColor];
                break;
            case 1:
                imageView.backgroundColor = [UIColor redColor];
                break;
            case 2:
                imageView.backgroundColor = [UIColor blueColor];
                break;
            default:
                break;
        }
        
        [_containerView addSubview:imageView];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeRight multiplier:(1.0 * i / imageCount) constant:0.0];
        [self.view addConstraints:@[width, height, top, left]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  curIndex = scrollView.contentOffset.x / self.view.frame.size.width;
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        if (curIndex == imageCount - 1) {
            if (_endCallBack) {
                _endCallBack();
            }
        }
    }

}

@end
