//
//  AddNewTaskViewController.m
//  ToDo
//
//  Created by James Gilmartin on 26/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import "AddNewTaskViewController.h"

@interface AddNewTaskViewController ()

@end

@implementation AddNewTaskViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set delegates
    self.titleTextField.delegate = self;
    self.notesTextView.delegate = self;
    
    // Set initial value for completion label
    self.completionLabel.text = @"0%";
    
    // Setup required Keyboards for various fields
    [self setUpModifiedKeyboards];
    
    // Initially disable save button
    self.saveBarButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Saving Record

- (IBAction)saveNewTask:(id)sender
{
    // Disable user interaction until save completes
    self.view.userInteractionEnabled = NO;
    
    // Open datastore
    self.datastore = [[DBDatastoreManager sharedManager] openDefaultDatastore:nil];
    
    // Add observer to detect when sve has finished
    __weak typeof(self) weakSelf = self;
    [self.datastore addObserver:self block:^{
        [weakSelf recordFinishedSaving];
    }];
    
    // Get instance of the table
    DBTable *toDoItems = [self.datastore getTable:@"toDoItems"];
    
    // Create the new element
    NSMutableDictionary *itemValues = [[NSMutableDictionary alloc] init];
    [itemValues setObject:self.titleTextField.text forKey:@"title"];
    [itemValues setObject:[NSNumber numberWithInteger:self.completionSlider.value] forKey:@"completed"];
    [itemValues setObject:[NSNumber numberWithInteger:self.prioritySegmentedControl.selectedSegmentIndex] forKey:@"priority"];
    if (self.deadline)
    {
        [itemValues setObject:self.deadline forKey:@"deadline"];
    }
    [itemValues setObject:self.notesTextView.text forKey:@"notes"];
    [itemValues setObject:[NSDate date] forKey:@"modified"];
    
    // Add the new element to the table
    [toDoItems insert:itemValues];
    
    // Sync datastores
    [self.datastore sync:nil];
}

- (void)recordFinishedSaving
{
    // stop listening for changes
    [self.datastore removeObserver:self];
    
    // Close the datastore
    if (self.datastore)
    {
        [self.datastore close];
    }
    
    self.datastore = nil;
    
    // Return to the table view controller
    [self performSegueWithIdentifier:@"rewindToList" sender:self];
}


#pragma mark - Navigation

- (IBAction)cancelNewTask:(id)sender
{
    // Return to the table view controller
    [self performSegueWithIdentifier:@"rewindToList" sender:self];
}


#pragma mark - User Input

- (IBAction)textFieldDidChange:(id)sender
{
    // Save button enabled only if the new element has a title
    if (self.titleTextField.text.length > 0)
    {
        self.saveBarButton.enabled = YES;
    }
    else
    {
        self.saveBarButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Close keyboard when return key pressed
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)sliderValueChanged:(id)sender
{
    // Update completion label
    self.completionLabel.text = [NSString stringWithFormat:@"%@%%", [NSNumber numberWithInteger:self.completionSlider.value]];
}

- (void)datePickerValueChanged: (UIDatePicker *)sender
{
    // Update deadline field and store the date
    self.deadlineTextField.text = [self formattedStringFromDate:sender.date];
    self.deadline = sender.date;
}

- (void)datePickerDone
{
    // Close the datepicker using done button on InputAccessory
    [self.deadlineTextField resignFirstResponder];
}

- (IBAction)clearDeadline:(id)sender
{
    // Clear deadline field and nullify the stored date
    self.deadlineTextField.text = @"";
    self.deadline = nil;
}

- (void)textViewDone
{
    // Close keyboard using done button on InputAccessory
    [self.notesTextView resignFirstResponder];
}


#pragma mark - Utilities

- (void)setUpModifiedKeyboards
{
    // Set up datepicker as input for deadline text field
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    // Add a toolbar with a done button
    UIToolbar *datePickerToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44)];
    datePickerToolbar.barStyle = UIBarStyleDefault;
    datePickerToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(datePickerDone)],
                               nil];
    [datePickerToolbar sizeToFit];
    
    // Set picker and toolbar as input for deadline text field
    [self.deadlineTextField setInputView:datePicker];
    [self.deadlineTextField setInputAccessoryView:datePickerToolbar];
    
    // Create toolbar with done button for text view
    UIToolbar *textViewToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44)];
    textViewToolbar.barStyle = UIBarStyleDefault;
    textViewToolbar.items = [NSArray arrayWithObjects:
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(textViewDone)],
                             nil];
    [textViewToolbar sizeToFit];
    
    // Set toolbar as accessory for notes text view
    [self.notesTextView setInputAccessoryView:textViewToolbar];
}

- (NSString *)formattedStringFromDate: (NSDate *)date
{
    // Create formatter
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yy HH:mm"];
    
    // Return formatted date
    return [dateFormat stringFromDate:date];
}

@end
