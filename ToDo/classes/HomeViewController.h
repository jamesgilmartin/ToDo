//
//  HomeViewController.h
//  ToDo
//
//  Created by James Gilmartin on 25/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>

@interface HomeViewController : UIViewController

@property (strong, nonatomic) DBDatastore *datastore;

@property (weak, nonatomic) IBOutlet UILabel *highPriorityTaskLabel;
@property (weak, nonatomic) IBOutlet UILabel *mediumPriorityTaskLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowPriorityTaskLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueTaskLabel;

@property (weak, nonatomic) IBOutlet UIButton *toggleDropboxButton;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

- (IBAction)viewTasks:(id)sender;
- (IBAction)toggleDropbox:(id)sender;

- (NSDate *)dateWithoutTimeComponents: (NSDate *)date;

@end
