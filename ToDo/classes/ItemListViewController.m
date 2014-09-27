//
//  ItemListViewController.m
//  ToDo
//
//  Created by James Gilmartin on 25/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import "ItemListViewController.h"

@interface ItemListViewController ()

@end

@implementation ItemListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Open the datastore
    self.datastore = [[DBDatastoreManager sharedManager] openDefaultDatastore:nil];
    
    // Set the order for the table (Highest priority first then ordered by completion)
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"fields.priority" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"fields.completed" ascending:YES]];
    
    // Observe changes to datastore list (possibly from other devices)
    __weak typeof(self) weakSelf = self;
    [[DBDatastoreManager sharedManager] addObserver:self block:^() {
        // Reload table to get changes
        [weakSelf.itemListTable reloadData];
    }];
    
    // Ensures table refreshes when returning from add / edit
    [self.itemListTable reloadData];
}


#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Rows need to be equal to the amount of items in our datastore
    DBTable *itemsTable = [self.datastore getTable:@"toDoItems"];
    return [[itemsTable query:nil error:nil] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Use the custom cell
    ItemListTableViewCell *cell = (ItemListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"itemListCell" forIndexPath:indexPath];
    
    // Load information from datastore
    DBTable *itemsTable = [self.datastore getTable:@"toDoItems"];
    NSArray *items = [[itemsTable query:nil error:nil] sortedArrayUsingDescriptors:self.sortDescriptors];
    DBRecord *item = [items objectAtIndex:indexPath.row];
    
    // Set background colour based on priority of task
    NSInteger priority = [item[@"priority"] integerValue];
    cell.backgroundColor = [self getColourForPriority:(int)priority];
    
    // Populate the field of the custom cell
    cell.completionLabel.text = [NSString stringWithFormat:@"%@", item[@"completed"]];
    cell.titleLabel.text = item[@"title"];
    cell.modifiedLabel.text = [NSString stringWithFormat:@"Modified: %@", [self formattedStringFromDate:item[@"modified"]]];
    if (item[@"deadline"])
    {
        cell.deadlineLabel.text = [NSString stringWithFormat:@"Deadline: %@", [self formattedStringFromDate:item[@"deadline"]]];
    }
    else
    {
        // Prevents (null) from being displayed
        cell.deadlineLabel.text = @"Deadline: n/a";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the record associated with the row
    DBTable *itemsTable = [self.datastore getTable:@"toDoItems"];
    NSArray *items = [[itemsTable query:nil error:nil] sortedArrayUsingDescriptors:self.sortDescriptors];
    DBRecord *item = [items objectAtIndex:indexPath.row];
    
    // Go to EditTaskViewController
    [self performSegueWithIdentifier:@"editTask" sender:item];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Height of our custom cell
    return 80;
}


#pragma mark - Navigation

- (IBAction)returnHome:(id)sender
{
    // Return to home screen
    [self performSegueWithIdentifier:@"returnHome" sender:self];
}

- (IBAction)addNewTask:(id)sender
{
    [self performSegueWithIdentifier:@"addNewTask" sender:self];
}

// Allow unwind segues to here
- (IBAction)unwindToListView: (UIStoryboardSegue *)segue{}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Close the current datastore
    if (self.datastore)
    {
        [self.datastore close];
    }
    
    self.datastore = nil;
    self.sortDescriptors = nil;
    
    // Stop listening for changes
    [[DBDatastoreManager sharedManager] removeObserver:self];
    
    // Check destination of Segue
    if ([segue.identifier isEqualToString:@"editTask"])
    {
        // If we are going to edit pass the relevent record to the View Controller
        EditTaskViewController *destination = [segue destinationViewController];
        destination.recordToEdit = sender;
    }
}


#pragma mark - Utility Functions

- (NSString *)formattedStringFromDate: (NSDate *)date
{
    // Returns a formatted NSString based on the supplied date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yy HH:mm"];
    
    return [dateFormatter stringFromDate:date];
}

- (UIColor *)getColourForPriority: (int)index
{
    // Returns a UIColor based on int supplied
    UIColor *colour;
    
    switch (index)
    {
        case 0:
            colour = [UIColor greenColor];
            break;
            
        case 1:
            colour = [UIColor yellowColor];
            break;
            
        case 2:
            colour = [UIColor redColor];
            break;
            
        default:
            colour = [UIColor clearColor];
            break;
    }
    
    return colour;
}

@end
