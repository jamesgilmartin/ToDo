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
}

- (void)linkCancelled: (NSNotification *)notification
{
    // Remove the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BDLoginFailed" object:nil];
    
    // Re-enable button without updating as the linking process was either cancelled or failed
    self.toggleDropboxButton.enabled = YES;
}

@end
