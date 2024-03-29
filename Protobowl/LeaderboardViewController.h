//
//  SideMenuViewController.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/20/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "SideMenuViewController.h"


@interface LeaderboardViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ProtobowlLeaderboardDelegate, UITextFieldDelegate, CellViewController>

@property (nonatomic, weak) MainViewController *mainViewController;

@end