//
//  ItemListViewController.h
//  ToDo
//
//  Created by James Gilmartin on 25/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>
#import "ItemListTableViewCell.h"
#import "EditTaskViewController.h"
#import "UIImageView+PercentageIndicator.h"

@interface ItemListViewController : UIViewController <UITableViewDataSource, UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, strong) DBDatastore *datastore;
@property (nonatomic, strong) NSMutableDictionary *queryDictionary;

@property (weak, nonatomic) IBOutlet UITableView *itemListTable;

- (IBAction)addNewTask:(id)sender;
- (IBAction)returnHome:(id)sender;
- (IBAction)showSortOptions:(id)sender;

- (UIColor *)getColourForPriority: (int)index;
- (NSString *)formattedStringFromDate: (NSDate *)dateToFormat forModified: (BOOL)modifiedText;

@end
