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
    
    // Quick way to test on new devices (only use once and comment out) - remove once app structure finished
    // [self populateDatabaseWithTestData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Close the current datastore
    {
        [self.datastore close];
    }
    
    self.datastore = nil;
    self.sortDescriptors = nil;
    
    // Stop listening for changes
    [[DBDatastoreManager sharedManager] removeObserver:self];
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
    NSLog(@"Selected row at index: %li", (long)indexPath.row);
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
    NSLog(@"Add new task function called");
}

// Allow unwind segues to here
- (IBAction)unwindToListView: (UIStoryboardSegue *)segue{}


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

- (void)populateDatabaseWithTestData
{
    // Saves test data in order to test table prior to full app functionality
    DBTable *toDoItems = [self.datastore getTable:@"toDoItems"];
    
    NSMutableDictionary *object1 = [[NSMutableDictionary alloc] init];
    [object1 setObject:@"Task 1" forKey:@"title"];
    [object1 setObject:@20 forKey:@"completed"];
    [object1 setObject:@1 forKey:@"priority"];
    [object1 setObject:[NSDate date] forKey:@"deadline"];
    [object1 setObject:@"" forKey:@"notes"];
    [object1 setObject:[NSDate date] forKey:@"modified"];
    [toDoItems insert:object1];
    
    NSMutableDictionary *object2 = [[NSMutableDictionary alloc] init];
    [object2 setObject:@"Task 2" forKey:@"title"];
    [object2 setObject:@40 forKey:@"completed"];
    [object2 setObject:@0 forKey:@"priority"];
    [object2 setObject:[NSDate date] forKey:@"deadline"];
    [object2 setObject:@"" forKey:@"notes"];
    [object2 setObject:[NSDate date] forKey:@"modified"];
    [toDoItems insert:object2];
    
    NSMutableDictionary *object3 = [[NSMutableDictionary alloc] init];
    [object3 setObject:@"Task 3" forKey:@"title"];
    [object3 setObject:@60 forKey:@"completed"];
    [object3 setObject:@2 forKey:@"priority"];
    [object3 setObject:[NSDate date] forKey:@"deadline"];
    [object3 setObject:@"" forKey:@"notes"];
    [object3 setObject:[NSDate date] forKey:@"modified"];
    [toDoItems insert:object3];
    
    NSMutableDictionary *object4 = [[NSMutableDictionary alloc] init];
    [object4 setObject:@"Task 4" forKey:@"title"];
    [object4 setObject:@80 forKey:@"completed"];
    [object4 setObject:@1 forKey:@"priority"];
    [object4 setObject:[NSDate date] forKey:@"deadline"];
    [object4 setObject:@"" forKey:@"notes"];
    [object4 setObject:[NSDate date] forKey:@"modified"];
    [toDoItems insert:object4];
    
    [self.datastore sync:nil];
}

@end
