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
    
    // Set the order for the table (Highest priority first then ordered by completion)
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"fields.modified" ascending:NO]];
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
    return [[itemsTable query:self.queryDictionary error:nil] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Use the custom cell
    ItemListTableViewCell *cell = (ItemListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"itemListCell" forIndexPath:indexPath];
    
    // Load information from datastore
    DBTable *itemsTable = [self.datastore getTable:@"toDoItems"];
    NSArray *items = [[itemsTable query:self.queryDictionary error:nil] sortedArrayUsingDescriptors:self.sortDescriptors];
    DBRecord *item = [items objectAtIndex:indexPath.row];
    
    // Set background colour based on priority of task
    NSInteger priority = [item[@"priority"] integerValue];
    UIColor *cellColour = [self getColourForPriority:(int)priority];
    cell.backgroundColor = cellColour;
    
    // Populate the field of the custom cell
    
    cell.completionLabel.text = [NSString stringWithFormat:@"%@%%", item[@"completed"]];
    [cell.completionImage drawCircleWithPercentage:[item[@"completed"] intValue] andTintColour:cellColour];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Height of our custom cell
    return 60;
}


#pragma mark - Navigation

- (IBAction)returnHome:(id)sender
{
    // Return to home screen
    [self performSegueWithIdentifier:@"returnHome" sender:self];
}

- (IBAction)showSortOptions:(id)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select sorting option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Sort by Completion",
                            @"Sort by Deadline",
                            @"Sort by Priority",
                            @"Sort by Modified",
                            @"Show / Hide Completed",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)addNewTask:(id)sender
{
    NSLog(@"Called");
    [self performSegueWithIdentifier:@"addNewTask" sender:self];
}

// Allow unwind segues to here
- (IBAction)unwindToListView: (UIStoryboardSegue *)segue{}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Check destination of Segue
    if ([[segue destinationViewController] isKindOfClass:[EditTaskViewController class]])
    {
        // If we are going to edit pass the relevent record to the View Controller
        DBTable *itemsTable = [self.datastore getTable:@"toDoItems"];
        NSArray *items = [[itemsTable query:self.queryDictionary error:nil] sortedArrayUsingDescriptors:self.sortDescriptors];
        DBRecord *item = [items objectAtIndex:[self.itemListTable indexPathForSelectedRow].row];
        EditTaskViewController *destination = [segue destinationViewController];
        destination.recordToEdit = item;
    }
    
    // Close the current datastore
    if (self.datastore)
    {
        [self.datastore close];
    }
    
    self.datastore = nil;
    self.sortDescriptors = nil;
    
    // Stop listening for changes
    [[DBDatastoreManager sharedManager] removeObserver:self];
}

#pragma mark - Sorting

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (popup.tag)
    {
        case 1:
        {
            switch (buttonIndex)
            {
                case 0:
                    // Sort by completion
                    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"fields.completed" ascending:NO]];
                    [self.itemListTable reloadData];
                    break;
                case 1:
                    // Sort by Deadline
                    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"fields.hasDeadline" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"fields.deadline" ascending:YES]];
                    [self.itemListTable reloadData];
                    break;
                case 2:
                    // Sort by Priority
                    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"fields.priority" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"fields.completed" ascending:YES]];
                    [self.itemListTable reloadData];
                    break;
                case 3:
                    // Sort by Modified
                    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"fields.modified" ascending:NO]];
                    [self.itemListTable reloadData];
                    break;
                case 4:
                    // Show / Hide Completed
                    [self toggleShowCompleted];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)toggleShowCompleted
{
    if (self.queryDictionary)
    {
        self.queryDictionary = nil;
        [self.itemListTable reloadData];
    }
    else
    {
        self.queryDictionary = [[NSMutableDictionary alloc] init];
        [self.queryDictionary setObject:@NO forKey:@"completedBOOL"];
        [self.itemListTable reloadData];
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
            // Green
            colour = [UIColor colorWithRed:(45.0/255.0) green:(144.0/255.0) blue:(68.0/255.0) alpha:1];
            break;
            
        case 1:
            // Orange
            colour = [UIColor colorWithRed:(216.0/255.0) green:(92.0/255.0) blue:(39.0/255.0) alpha:1];
            break;
            
        case 2:
            // Red
            colour = [UIColor colorWithRed:(201.0/255.0) green:(32.0/255.0) blue:(55.0/255.0) alpha:1];
            break;
            
        default:
            colour = [UIColor clearColor];
            break;
    }
    
    return colour;
}



@end
