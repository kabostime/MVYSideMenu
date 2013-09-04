//
//  MVYSideMenuController.h
//  MVYSideMenuExample
//
//  Created by Álvaro Murillo del Puerto on 10/07/13.
//  Copyright (c) 2013 Mobivery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVYSideMenuOptions.h"

typedef NS_ENUM(NSInteger, MVYSideMenuSide){
	MVYSideMenuLeft,
	MVYSideMenuRight
};

@interface MVYSideMenuController : UIViewController

@property (nonatomic, strong, readonly) UIViewController *leftViewController;
@property (nonatomic, strong, readonly) UIViewController *rightViewController;
@property (nonatomic, strong, readonly) UIViewController *contentViewController;
@property (nonatomic, copy) MVYSideMenuOptions *options;

- (id)initWithMenuViewController:(UIViewController *)leftViewController rightViewController:(UIViewController *)rightViewController contentViewController:(UIViewController *)contentViewController;
- (id)initWithMenuViewController:(UIViewController *)leftViewController rightViewController:(UIViewController *)rightViewController contentViewController:(UIViewController *)contentViewController options:(MVYSideMenuOptions *)options;
- (void)closeMenu;
- (void)openMenu:(MVYSideMenuSide)side;
- (void)disable;
- (void)enable;
- (void)changeContentViewController:(UIViewController *)contentViewController closeMenu:(BOOL)closeMenu;
- (void)changeLeftViewController:(UIViewController *)leftViewController closeMenu:(BOOL)closeMenu;
- (void)changeRightViewController:(UIViewController *)rightViewController closeMenu:(BOOL)closeMenu;

@end

@interface UIViewController (MVYSideMenuController)
- (MVYSideMenuController *)sideMenuController;
@end
