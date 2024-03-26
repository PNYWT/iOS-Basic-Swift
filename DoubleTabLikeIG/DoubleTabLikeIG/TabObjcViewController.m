//
//  TabObjcViewController.m
//  DoubleTabLikeIG
//
//  Created by Train2 on 8/8/2565 BE.
//

#import "TabObjcViewController.h"

@interface TabObjcViewController ()

@end

@implementation TabObjcViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addGestureRecongizers];
}

//MARK: TEST Gesture Recognizers
- (void) addGestureRecongizers{
    UITapGestureRecognizer *tapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapTap];
}

-(void) didTap:(UITapGestureRecognizer*) gesture{
    
    UIView *gestureView = gesture.view;
    
    CGPoint locationTap = [gesture locationInView:gesture.view];
    
    UIImageView *heart = [[UIImageView alloc] initWithFrame:CGRectMake(locationTap.x-50, locationTap.y-50,gestureView.frame.size.width / 4, gestureView.frame.size.width / 4)];
    heart.image = [UIImage imageNamed:@"filter_age_thumbview"];
    heart.backgroundColor = [UIColor redColor];
    [gestureView addSubview:heart];
    
    NSTimeInterval delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1 animations:^{
            heart.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished){
                [heart removeFromSuperview];
            }
        }];
    });
}
@end
