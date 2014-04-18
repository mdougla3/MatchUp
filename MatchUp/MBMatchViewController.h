//
//  MBMatchViewController.h
//  MatchUp
//
//  Created by Illinois Business on 4/16/14.
//  Copyright (c) 2014 McCay. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBMatchViewContollerDelegate <NSObject>

-(void)presentMatchesViewController;

@end

@interface MBMatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;
@property (weak) id <MBMatchViewContollerDelegate> delegate;


@end
