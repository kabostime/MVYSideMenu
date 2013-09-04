//
//  MVYSideMenuController.m
//  MVYSideMenuExample
//
//  Created by Álvaro Murillo del Puerto on 10/07/13.
//  Copyright (c) 2013 Mobivery. All rights reserved.
//

#import "MVYSideMenuController.h"
#import <QuartzCore/QuartzCore.h>


typedef NS_ENUM(NSInteger, MVYSideMenuAction){
	MVYSideMenuOpen,
	MVYSideMenuClose
};

typedef struct {
	MVYSideMenuAction menuAction;
	BOOL shouldBounce;
	CGFloat velocity;
} MVYSideMenuPanResultInfo;

@interface MVYSideMenuController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *contentContainerView;
@property (strong, nonatomic) UIView *leftContainerView;
@property (strong, nonatomic) UIView *rightContainerView;
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation MVYSideMenuController

- (id)initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder:aDecoder];
	if (self) {
		_options = [[MVYSideMenuOptions alloc] init];
	}
	
	return self;
}

- (id)initWithMenuViewController:(UIViewController *)leftViewController
             rightViewController:(UIViewController *)rightViewController
		   contentViewController:(UIViewController *)contentViewController {
	
	return [self initWithMenuViewController:leftViewController
                        rightViewController:rightViewController
					  contentViewController:contentViewController
									options:[[MVYSideMenuOptions alloc] init]];
}

- (id)initWithMenuViewController:(UIViewController *)leftViewController
             rightViewController:(UIViewController *)rightViewController
		   contentViewController:(UIViewController *)contentViewController
						 options:(MVYSideMenuOptions *)options {
	
	self = [super init];
	if(self){
		_options = options;
		_leftViewController = leftViewController;
        _rightViewController = rightViewController;
		_contentViewController = contentViewController;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self setUpMenuViewController:_leftViewController side:MVYSideMenuLeft];
    [self setUpMenuViewController:_rightViewController side:MVYSideMenuRight];

	[self setUpContentViewController:_contentViewController];
	
	[self addGestures];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRightViewController:(UIViewController *)rightViewController{
	
	[self removeViewController:_rightViewController];
	
	_rightViewController = rightViewController;
	
	[self setUpMenuViewController:_rightViewController side:MVYSideMenuRight];
}

- (void)setLeftViewController:(UIViewController *)leftViewController{
	
	[self removeViewController:_leftViewController];
	
	_leftViewController = leftViewController;
	
	[self setUpMenuViewController:_leftViewController side:MVYSideMenuLeft];
}

- (void)setContentViewController:(UIViewController *)contentViewController {
	
	[self removeViewController:_contentViewController];
	
	_contentViewController = contentViewController;
	
	[self setUpContentViewController:_contentViewController];
	
}

- (void)closeMenu {
	if([self isLeftMenuOpen]){
       	[self closeMenuWithVelocity:0.0f side:MVYSideMenuLeft];
    } else if ([self isRightMenuOpen]){
        [self closeMenuWithVelocity:0.0f side:MVYSideMenuRight];
    }
}

- (void)openMenu:(MVYSideMenuSide)side {
	
	[self openMenuWithVelocity:0.0f side:(MVYSideMenuSide)side];
}

- (void)disable {
	self.panGesture.enabled = NO;
}

- (void)enable {
	self.panGesture.enabled = YES;
}

- (void)changeContentViewController:(UIViewController *)contentViewController closeMenu:(BOOL)closeMenu {
	
	self.contentViewController = contentViewController;
	closeMenu ? [self closeMenu] : nil;
}

- (void)changeRightViewController:(UIViewController *)rightViewController closeMenu:(BOOL)closeMenu {
	self.rightViewController = rightViewController;
	closeMenu ? [self closeMenu] : nil;
}

- (void)changeLeftViewController:(UIViewController *)leftViewController closeMenu:(BOOL)closeMenu {
	self.leftViewController = leftViewController;
	closeMenu ? [self closeMenu] : nil;
}

#pragma mark – Private methods

- (void)removeViewController:(UIViewController *)menuViewController {
	
	if (menuViewController) {
		[menuViewController willMoveToParentViewController:nil];
		[menuViewController.view removeFromSuperview];
		[menuViewController removeFromParentViewController];
	}
}

- (void)setUpMenuViewController:(UIViewController *)menuViewController side:(MVYSideMenuSide)side {
	
	if (menuViewController) {
        if (side == MVYSideMenuLeft) {
            [self addChildViewController:menuViewController];
            menuViewController.view.frame = self.leftContainerView.bounds;
            [self.leftContainerView addSubview:menuViewController.view];
            [menuViewController didMoveToParentViewController:self];
        } else if ( side == MVYSideMenuRight) {
            [self addChildViewController:menuViewController];
            menuViewController.view.frame = self.rightContainerView.bounds;
            [self.rightContainerView addSubview:menuViewController.view];
            [menuViewController didMoveToParentViewController:self];

        }
	}
}

- (void)setUpContentViewController:(UIViewController *)contentViewController {
	
	if (contentViewController) {
		[self addChildViewController:contentViewController];
		contentViewController.view.frame = self.contentContainerView.bounds;
		[self.contentContainerView addSubview:contentViewController.view];
		[contentViewController didMoveToParentViewController:self];
	}
	
}

- (UIView *)opacityView {

	if (!_opacityView) {
		_opacityView = [[UIView alloc] initWithFrame:self.view.bounds];
        _opacityView.backgroundColor = [UIColor blackColor];
        _opacityView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_opacityView.layer.opacity = 0.0;
        
        [self.view insertSubview:_opacityView atIndex:1];
	}
	
	return _opacityView;
}

- (UIView *)contentContainerView {
    if (!_contentContainerView) {
        _contentContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
        _contentContainerView.backgroundColor = [UIColor clearColor];
        _contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self.view insertSubview:_contentContainerView atIndex:0];
    }
    
    return _contentContainerView;
}

- (UIView *)rightContainerView {
    if (!_rightContainerView) {
		CGRect frame = self.view.bounds;
		frame.size.width = frame.size.width - self.options.menuViewOverlapWidth;
		frame.origin.x = [self menuMaxOrigin:MVYSideMenuRight];
        _rightContainerView = [[UIView alloc] initWithFrame:frame];
        _rightContainerView.backgroundColor = [UIColor clearColor];
        _rightContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        [self.view insertSubview:_rightContainerView atIndex:2];
    }
    
    return _rightContainerView;
}

- (UIView *)leftContainerView {
    if (!_leftContainerView) {
		CGRect frame = self.view.bounds;
		frame.size.width = frame.size.width - self.options.menuViewOverlapWidth;
		frame.origin.x = [self menuMinOrigin:MVYSideMenuLeft];
        _leftContainerView = [[UIView alloc] initWithFrame:frame];
        _leftContainerView.backgroundColor = [UIColor clearColor];
        _leftContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        [self.view insertSubview:_leftContainerView atIndex:2];
    }
    
    return _leftContainerView;
}

- (void)addGestures {
	
    if (!_panGesture) {
        // _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
		// [_panGesture setDelegate:self];
        // [self.view addGestureRecognizer:_panGesture];
    }
	
	if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
        [_tapGesture setDelegate:self];
		[self.view addGestureRecognizer:_tapGesture];
    }
}

/*
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
	
	static CGRect menuFrameAtStartOfPan;
	static BOOL isMenuAppearing;
	
	switch (panGesture.state) {
		case UIGestureRecognizerStateBegan:
            if ([self isLeftMenuOpen]){
                menuFrameAtStartOfPan = self.leftContainerView.frame;
                isMenuAppearing = [self isLeftMenuHidden];
                [self.leftViewController beginAppearanceTransition:isMenuAppearing animated:YES];
                [self addShadowToMenuView:MVYSideMenuLeft];
                break;
            } else {
                menuFrameAtStartOfPan = self.rightContainerView.frame;
                isMenuAppearing = [self isRightMenuHidden];
                [self.rightViewController beginAppearanceTransition:isMenuAppearing animated:YES];
                [self addShadowToMenuView:MVYSideMenuRight];
                break;

            }
			
		case UIGestureRecognizerStateChanged:{
			CGPoint translation = [panGesture translationInView:panGesture.view];
			self.menuContainerView.frame = [self applyTranslation:translation toFrame:menuFrameAtStartOfPan];
			[self applyOpacity];
			[self applyContentViewScale];
			break;
		}
			
		case UIGestureRecognizerStateEnded:{
			[self.menuViewController beginAppearanceTransition:!isMenuAppearing animated:YES];
			
			CGPoint velocity = [panGesture velocityInView:panGesture.view];
			MVYSideMenuPanResultInfo panInfo = [self panResultInfoForVelocity:velocity side:side];
			
			if (panInfo.menuAction == MVYSideMenuOpen) {
				[self openMenuWithVelocity:panInfo.velocity side:side];
			} else {
				[self closeMenuWithVelocity:panInfo.velocity side:side];
			}
			break;
		}
			
		default:
			break;
	}
}

- (MVYSideMenuPanResultInfo)panResultInfoForVelocity:(CGPoint)velocity side:(MVYSideMenuSide)side {
	
	static CGFloat thresholdVelocity = 450.0f;
    CGFloat pointOfNoReturn;
    CGFloat menuOrigin;
    
    if (side == MVYSideMenuLeft) {
        pointOfNoReturn = floorf([self menuMinOrigin:side] / 2.0f);
        menuOrigin = self.leftContainerView.frame.origin.x;
    } else {
        pointOfNoReturn = floorf((self.view.bounds.size.width + self.options.menuViewOverlapWidth) / 2.0f);
        menuOrigin = self.rightContainerView.frame.origin.x;
    }

	MVYSideMenuPanResultInfo panInfo = {MVYSideMenuClose, NO, 0.0f};
	
	panInfo.menuAction = menuOrigin <= pointOfNoReturn ? MVYSideMenuClose : MVYSideMenuOpen;
	
	if (velocity.x >= thresholdVelocity) {
		panInfo.menuAction = MVYSideMenuOpen;
		panInfo.velocity = velocity.x;
	} else if (velocity.x <= (-1.0f * thresholdVelocity)) {
		panInfo.menuAction = MVYSideMenuClose;
		panInfo.velocity = velocity.x;
	}
	
	return panInfo;
}
 */

- (BOOL)isLeftMenuOpen {
	return self.leftContainerView.frame.origin.x == 0.0f;
}

- (BOOL)isRightMenuOpen {
	return self.rightContainerView.frame.origin.x == self.options.menuViewOverlapWidth;
}

- (BOOL)isLeftMenuHidden {
	return self.leftContainerView.frame.origin.x <= [self menuMinOrigin:MVYSideMenuLeft];
}

- (BOOL)isRightMenuHidden {
	return self.rightContainerView.frame.origin.x >= [self menuMaxOrigin:MVYSideMenuRight];
}

- (CGFloat)menuMaxOrigin:(MVYSideMenuSide)side {
    if (side == MVYSideMenuLeft){
        return 0.0f;
    } else {
        return self.view.bounds.size.width;
    }
}

- (CGFloat)menuMinOrigin:(MVYSideMenuSide)side {
    if (side == MVYSideMenuLeft){
        return -(self.view.bounds.size.width - self.options.menuViewOverlapWidth);
    } else {
        return self.options.menuViewOverlapWidth;
    }
}

- (CGRect)applyTranslation:(CGPoint)translation toFrame:(CGRect)frame side:(MVYSideMenuSide)side {
	
	CGFloat newOrigin = frame.origin.x;
    newOrigin += translation.x;
	
    CGFloat minOrigin = [self menuMinOrigin:side];
    CGFloat maxOrigin = [self menuMaxOrigin:side];

    CGRect newFrame = frame;
    
    if (newOrigin < minOrigin) {
        newOrigin = minOrigin;
    } else if (newOrigin > maxOrigin) {
        newOrigin = maxOrigin;
    }
	
    newFrame.origin.x = newOrigin;
    return newFrame;
}

- (CGFloat)getOpenedMenuRatio:(MVYSideMenuSide)side{
	
	CGFloat width = self.view.bounds.size.width - self.options.menuViewOverlapWidth;
	CGFloat currentPosition;
    if(side == MVYSideMenuLeft){
        currentPosition = self.leftContainerView.frame.origin.x - [self menuMinOrigin:side];
    } else {
        currentPosition = [self menuMaxOrigin:side] - self.rightContainerView.frame.origin.x;
    }
	return currentPosition / width;
}

- (void)applyOpacity:(MVYSideMenuSide)side {
	
	CGFloat openedMenuRatio = [self getOpenedMenuRatio:side];
	CGFloat opacity = self.options.contentViewOpacity * openedMenuRatio;
	self.opacityView.layer.opacity = opacity;
}

- (void)applyContentViewScale:(MVYSideMenuSide)side {

	CGFloat openedMenuRatio = [self getOpenedMenuRatio:side];
	CGFloat scale = 1.0 - ((1.0 - self.options.contentViewScale) * openedMenuRatio);
	
	[self.contentContainerView setTransform:CGAffineTransformMakeScale(scale, scale)];
}

- (void)openMenuWithVelocity:(CGFloat)velocity side:(MVYSideMenuSide)side {
	
    CGFloat startXOrigin;
    CGFloat finalXOrigin;
    CGRect frame;
	
    if(side == MVYSideMenuLeft){
        startXOrigin = self.leftContainerView.frame.origin.x;
        finalXOrigin = [self menuMaxOrigin:MVYSideMenuLeft];
        frame = self.leftContainerView.frame;
    } else {
        startXOrigin = self.rightContainerView.frame.origin.x;
        finalXOrigin = [self menuMinOrigin:MVYSideMenuRight];
        frame = self.rightContainerView.frame;
    }
    
	frame.origin.x = finalXOrigin;
	
	NSTimeInterval duration;
	if (velocity == 0.0f) {
        duration = self.options.animationDuration;        
	} else {
		duration = fabs(startXOrigin - finalXOrigin) / velocity;
		duration = fmax(0.1, fmin(1.0f, duration));
	}
	
	[self addShadowToMenuView:side];
	
	[UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if(side == MVYSideMenuLeft){
            self.leftContainerView.frame = frame;
        } else {
            self.rightContainerView.frame = frame;
        }
		self.opacityView.layer.opacity = self.options.contentViewOpacity;
		[self.contentContainerView setTransform:CGAffineTransformMakeScale(self.options.contentViewScale, self.options.contentViewScale)];
	} completion:^(BOOL finished) {
		[self disableContentInteraction];
	}];
}

- (void)closeMenuWithVelocity:(CGFloat)velocity side:(MVYSideMenuSide)side {
	
	CGFloat menuXOrigin;
	CGFloat finalXOrigin;
    CGRect frame;
    
    if(side == MVYSideMenuLeft) {
        menuXOrigin = self.leftContainerView.frame.origin.x;
        finalXOrigin = [self menuMinOrigin:side];
        frame = self.leftContainerView.frame;
    } else {
        menuXOrigin = self.rightContainerView.frame.origin.x;
        finalXOrigin = [self menuMaxOrigin:side];
        frame = self.rightContainerView.frame;
    }
	
	frame.origin.x = finalXOrigin;
	
	NSTimeInterval duration;
	if (velocity == 0.0f) {
        duration = self.options.animationDuration;        
	} else {
		duration = fabs(menuXOrigin - finalXOrigin) / velocity;
		duration = fmax(0.1, fmin(1.0f, duration));
	}
	
	[UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if(side == MVYSideMenuLeft){
            self.leftContainerView.frame = frame;
        } else {
            self.rightContainerView.frame = frame;
        }
		self.opacityView.layer.opacity = 0.0f;
		[self.contentContainerView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
	} completion:^(BOOL finished) {
		[self removeMenuShadow:side];
		[self enableContentInteraction];
	}];
}

- (BOOL)slideMenuForGestureRecognizer:(UIGestureRecognizer *)gesture withTouchPoint:(CGPoint)point {
	
	BOOL slide = [self isLeftMenuOpen] || [self isRightMenuOpen];
	
	slide |= self.options.panFromBezel && [self isPointContainedWithinBezelRect:point];
	
	slide |= self.options.panFromNavBar && [self isPointContainedWithinNavigationRect:point];
	
	return slide;
}

-(BOOL)isPointContainedWithinNavigationRect:(CGPoint)point {
    CGRect navigationBarRect = CGRectNull;
    if([self.contentViewController isKindOfClass:[UINavigationController class]]){
        UINavigationBar * navBar = [(UINavigationController*)self.contentViewController navigationBar];
        navigationBarRect = [navBar convertRect:navBar.frame toView:self.view];
        navigationBarRect = CGRectIntersection(navigationBarRect,self.view.bounds);
    }
    return CGRectContainsPoint(navigationBarRect,point);
}

-(BOOL)isPointContainedWithinBezelRect:(CGPoint)point {
    CGRect leftBezelRect;
    CGRect tempRect;
	CGFloat bezelWidth = self.options.bezelWidth;
	
    CGRectDivide(self.view.bounds, &leftBezelRect, &tempRect, bezelWidth, CGRectMinXEdge);
    
    return CGRectContainsPoint(leftBezelRect, point);
}

- (BOOL)isPointContainedWithinMenuRect:(CGPoint)point side:(MVYSideMenuSide)side {
    if(side == MVYSideMenuLeft){
        return CGRectContainsPoint(self.leftContainerView.frame, point);
        
    } else {
        return CGRectContainsPoint(self.rightContainerView.frame, point);
    }
}

- (void)addShadowToMenuView:(MVYSideMenuSide)side {
	
    if (side == MVYSideMenuLeft) {
        self.leftContainerView.layer.masksToBounds = NO;
        self.leftContainerView.layer.shadowOffset = self.options.shadowOffset;
        self.leftContainerView.layer.shadowOpacity = self.options.shadowOpacity;
        self.leftContainerView.layer.shadowRadius = self.options.shadowRadius;
        self.leftContainerView.layer.shadowPath = [[UIBezierPath
                                                    bezierPathWithRect:self.leftContainerView.bounds] CGPath];
    } else {
        self.rightContainerView.layer.masksToBounds = NO;
        self.rightContainerView.layer.shadowOffset = self.options.shadowOffset;
        self.rightContainerView.layer.shadowOpacity = self.options.shadowOpacity;
        self.rightContainerView.layer.shadowRadius = self.options.shadowRadius;
        self.rightContainerView.layer.shadowPath = [[UIBezierPath
                                                    bezierPathWithRect:self.rightContainerView.bounds] CGPath];
    }
}

- (void)removeMenuShadow:(MVYSideMenuSide)side {
	
    if(side == MVYSideMenuLeft){
        self.leftContainerView.layer.masksToBounds = YES;
    } else {
        self.rightContainerView.layer.masksToBounds = YES;
    }
	self.contentContainerView.layer.opacity = 1.0;
}

- (void)removeContentOpacity {
	self.opacityView.layer.opacity = 0.0;
}

- (void)addContentOpacity {
	self.opacityView.layer.opacity = self.options.contentViewOpacity;
}

- (void)disableContentInteraction {
	[self.contentContainerView setUserInteractionEnabled:NO];
}

- (void)enableContentInteraction {
	[self.contentContainerView setUserInteractionEnabled:YES];
}

#pragma mark – UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	
	CGPoint point = [touch locationInView:self.view];
	
	if (gestureRecognizer == _panGesture) {
		return [self slideMenuForGestureRecognizer:gestureRecognizer withTouchPoint:point];
	} else if (gestureRecognizer == _tapGesture){
		return ([self isLeftMenuOpen] && ![self isPointContainedWithinMenuRect:point side:MVYSideMenuLeft]) || ([self isRightMenuOpen] && ![self isPointContainedWithinMenuRect:point side:MVYSideMenuRight]);
	}
	
	return YES;
}

@end

@implementation UIViewController (MVYSideMenuController)

- (MVYSideMenuController *)sideMenuController {
	
    UIViewController *viewController = self;
    
    while (viewController) {
        if ([viewController isKindOfClass:[MVYSideMenuController class]])
            return (MVYSideMenuController *)viewController;
        
        viewController = viewController.parentViewController;
    }
    return nil;
}

@end
