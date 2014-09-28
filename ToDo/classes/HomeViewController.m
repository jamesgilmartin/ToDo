//
//  HomeViewController.m
//  ToDo
//
//  Created by James Gilmartin on 25/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
    // Check if app has been linked to a Dropbox account
    if (account)
    {
        // App has been linked to an account
        [self.toggleDropboxButton setTitle:@"Unlink Dropbox" forState:UIControlStateNormal];
        self.accountLabel.text = [NSString stringWithFormat:@"Linked with account: %@", account.info.displayName];
    }
    else
    {
        // App has not been linked
        [self.toggleDropboxButton setTitle:@"Link to Dropbox" forState:UIControlStateNormal];
        
        // Hide the account information
        self.accountLabel.hidden = YES;
    }
    
    // Add observer to detect changes in DBAccountManager (i.e link / unlink)
    [[DBAccountManager sharedManager] addObserver:self block:^(DBAccount *account) {
        
        // Has the app just been linked to an account?
        if (account.isLinked)
        {
            // If a new link has been created we need to add an observer to indicate when new user info has finished syncing
            [account addObserver:self block:^{
                
                // Update the account information
                [self updateAccountInformationAfterLinking];
            }];
        }
    }];

}

- (void)viewDidAppear:(BOOL)animated
{
    // Load summary of tasks. Delay is to allow table to close datastore when returning from table.
    [self performSelector:@selector(loadTaskData) withObject:nil afterDelay:0.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (IBAction)viewTasks:(id)sender
{
    [self performSegueWithIdentifier:@"HomeToList" sender:self];
}

-(IBAction)unwindToHome: (UIStoryboardSegue *)segue{}


#pragma mark - Dropbox Login

- (IBAction)toggleDropbox:(id)sender
{
    // Retreive the linked Dropbox Account
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (account)
    {
        // If account exists, remove it
        
        // Unlink from Dropbox
        [account unlink];
        
        // Shutdown and stop listening for changes to the datastores
        [[DBDatastoreManager sharedManager] shutDown];
        [[DBDatastoreManager sharedManager] removeObserver:self];
        
        // Use local datastores
        [DBDatastoreManager setSharedManager:[DBDatastoreManager localManagerForAccountManager:[DBAccountManager sharedManager]]];
        
        // Update button to reflect the changes
        [self.toggleDropboxButton setTitle:@"Link to Dropbox" forState:UIControlStateNormal];
        
        // Hide the account information from display
        self.accountLabel.hidden = YES;
        
        [self loadTaskData];
    }
    else
    {
        // If account does not exist, create it
        
        // Add observer to detect non completion
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linkCancelled:) name:@"DBLoginFailed" object:nil];
        
        // Display Login
        [[DBAccountManager sharedManager] linkFromController:self];
        
        // Disable button until asychronous tasks complete (loading user info etc) or process is cancelled / fails
        self.toggleDropboxButton.enabled = NO;
    }
}

- (void)updateAccountInformationAfterLinking
{
    // Update button now that an account is linked
    [self.toggleDropboxButton setTitle:@"Unlink Dropbox" forState:UIControlStateNormal];
    
    // Re-enable button
    self.toggleDropboxButton.enabled = YES;
    
    // Get the new account object
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (account)
    {
        // Get the accounts display name in order to display it
        self.accountLabel.text = [NSString stringWithFormat:@"Linked with account: %@", account.info.displayName];
        
        // Remove the observer from the DBAccount object as we now have the required information
        [account removeObserver:self];
        
        // Unhide the account information
        self.accountLabel.hidden = NO;
    }
    
    [self loadTaskData];
}

- (void)linkCancelled: (NSNotification *)notification
{
    // Remove the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BDLoginFailed" object:nil];
    
    // Re-enable button without updating as the linking process was either cancelled or failed
    self.toggleDropboxButton.enabled = YES;
}

- (void)loadTaskData
{
    self.datastore = [[DBDatastoreManager sharedManager] openDefaultDatastore:nil];
    DBTable *itemsTable = [self.datastore getTable:@"toDoItems"];
    
    int hpTasks = (int)[[itemsTable query:@{ @"priority": @2, @"completedBOOL": @NO } error:nil] count];
    NSString *highPriorityLabelString;
    if (hpTasks == 1)
    {
        highPriorityLabelString = @"High priority task still to complete";
    }
    else
    {
        highPriorityLabelString = @"High priority tasks still to complete";
    }
    self.highPriorityTaskLabel.text = [NSString stringWithFormat:@"%i %@", hpTasks, highPriorityLabelString];
    
    int mpTasks = (int)[[itemsTable query:@{ @"priority": @1, @"completedBOOL": @NO } error:nil] count];
    NSString *mediumPriorityLabelString;
    if (mpTasks == 1)
    {
        mediumPriorityLabelString = @"Medium priority task still to complete";
    }
    else
    {
        mediumPriorityLabelString = @"Medium priority tasks still to complete";
    }
    self.mediumPriorityTaskLabel.text = [NSString stringWithFormat:@"%i %@", mpTasks, mediumPriorityLabelString];
    
    int lpTasks = (int)[[itemsTable query:@{ @"priority": @0, @"completedBOOL": @NO } error:nil] count];
    NSString *lowPriorityLabelString;
    if (mpTasks == 1)
    {
        lowPriorityLabelString = @"Low priority task still to complete";
    }
    else
    {
        lowPriorityLabelString = @"Low priority tasks still to complete";
    }
    self.lowPriorityTaskLabel.text = [NSString stringWithFormat:@"%i %@", lpTasks, lowPriorityLabelString];
    
    int todayTasks = (int)[[itemsTable query:@{ @"roundedDeadline": [self dateWithoutTimeComponents:[NSDate date]] } error:nil] count];
    NSString *dueTaskLabelString;
    if (todayTasks == 1)
    {
        dueTaskLabelString = @"Task to complete today";
    }
    else
    {
        dueTaskLabelString = @"Tasks to complete today";
    }
    self.dueTaskLabel.text = [NSString stringWithFormat:@"%i %@", todayTasks, dueTaskLabelString];
    
    [self.datastore close];
    self.datastore = nil;
}

- (NSDate *)dateWithoutTimeComponents: (NSDate *)date
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    return [calendar dateFromComponents:[calendar components:preservedComponents fromDate:date]];
}

@end
