//
//  ImageViewController.h
//
// Usage:
//
//- (IBAction) testMethod:(UIButton *)sender {
//    ImageViewController *imgCtrl = [[ImageViewController alloc] init];
//    imgCtrl.keyWindow = [[UIApplication sharedApplication] keyWindow];
//    imgCtrl.image = [UIImage imageNamed:@"test.jpg"];
//    imgCtrl.declineImage = _declineImage.on;
//
//    imgCtrl.returnBlock = ^ {
//        [self dismissViewControllerAnimated:NO completion:nil];
//    };
//
//    [self presentViewController:imgCtrl animated:NO completion:nil];
//}
//


#import <UIKit/UIKit.h>

@interface RichPhotoView : UIScrollView
@property(nonatomic, weak) UIViewController *parentController;
@property(nonatomic, strong) dispatch_block_t returnBlock;
@property(nonatomic, assign) BOOL declineImage;
- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image;
@end

@interface ImageViewController : UIViewController
@property(nonatomic, weak) UIView *keyWindow;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, assign) BOOL declineImage;
@property(nonatomic, strong) dispatch_block_t returnBlock;
@end
