//
//  SideMenuViewController.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/20/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIView+Donald.h"
#import "UIColor+MoreConstructors.h"
#import "SwitchCell.h"
#import "RadioCell.h"
#import "ActionCell.h"
#import "NSDictionary+MutableDeepCopy.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#define kLeaderboardCellHeight 44
#define kLeaderboardDetailCellHeight 180


NSString *SettingsCellTypeBool = @"SettingsCellTypeBool";
NSString *SettingsCellTypeRadio = @"SettingsCellTypeRadio";
NSString *SettingsCellTypeAction = @"SettingsCellTypeAction";

@interface SettingsCellDescriptor : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic) NSString *type;
@end

@implementation SettingsCellDescriptor
@end


@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic) int groupCount;
@property (nonatomic, strong) NSMutableDictionary *rootDict;
@end

@implementation SettingsViewController
@synthesize sideMenuViewController;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.sideMenuViewController reloadTableView];
}

- (float) expandedHeight
{
    return 480;
}


- (void) setupWithPlistPath:(NSString *)path
{
    self.filePath = path;
    
    NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:path];
    self.rootDict = [rootDict mutableDeepCopy];
    
    [self.settingsTableView reloadData];
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *groupKey = self.rootDict[@"GroupOrder"][section];
    NSDictionary *groupDict = self.rootDict[groupKey];
    NSArray *rowOrder = groupDict[@"RowOrder"];
    
    return rowOrder.count;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *groupOrder = self.rootDict[@"GroupOrder"];
    return groupOrder.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *groupKey = self.rootDict[@"GroupOrder"][section];
    return groupKey;
}

#define kValuePathKey @"ValuePathKey"
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *groupKey = self.rootDict[@"GroupOrder"][indexPath.section];
    NSDictionary *groupDict = self.rootDict[groupKey];
    NSArray *rowOrder = groupDict[@"RowOrder"];
    NSString *rowKey = rowOrder[indexPath.row];
    NSDictionary *row = groupDict[rowKey];
    
    NSString *rowType = row[@"SettingsCellType"];
    UITableViewCell *cell = nil;
    if([rowType isEqualToString:SettingsCellTypeBool])
    {
        NSString *valuePath = [NSString stringWithFormat:@"%@.%@", groupKey, rowKey];
        NSNumber *objVal = [[NSUserDefaults standardUserDefaults] objectForKey:valuePath];
        BOOL value;
        if(objVal)
        {
            value = [objVal boolValue];
        }
        else
        {
            value = [row[@"value"] boolValue];
        }
        cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
        ((SwitchCell *)cell).titleLabel.text = rowKey;
        ((SwitchCell *)cell).switchControl.on = value;
        
        [((SwitchCell *)cell).switchControl addTarget:self action:@selector(cellSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        objc_setAssociatedObject(((SwitchCell *)cell).switchControl, kValuePathKey, valuePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else if([rowType isEqualToString:SettingsCellTypeRadio])
    {
        int value = [row[@"value"] intValue];
        NSArray *options = row[@"options"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
        ((RadioCell *)cell).titleLabel.text = rowKey;
        ((RadioCell *)cell).selection = value;
        ((RadioCell *)cell).options = options;
    }
    else if([rowType isEqualToString:SettingsCellTypeAction])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];
        ((ActionCell *)cell).titleLabel.text = rowKey;
        ((ActionCell *)cell).callback = nil;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];
    }
    
    return cell;
}

- (void) cellSwitchChanged:(UISwitch *)sw
{
    NSString *valuePath = objc_getAssociatedObject(sw, kValuePathKey);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:sw.isOn] forKey:valuePath];
    [defaults synchronize];
    NSLog(@"path: %@", valuePath);
}

@end