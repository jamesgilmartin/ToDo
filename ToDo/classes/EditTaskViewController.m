//
//  EditTaskViewController.m
//  ToDo
//
//  Created by James Gilmartin on 26/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import "EditTaskViewController.h"

@interface EditTaskViewController ()

@end

@implementation EditTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Open the datastore
    self.datastore = [[DBDatastoreManager sharedManager] openDefaultDatastore:nil];
    
    // Add observer to listen for changes
    __weak typeof(self) weakSelf = self;
    [self.datastore addObserver:self block:^{
        [weakSelf recordFinishedUpdating];
    }];
    
    // Set delegates for text elements
    self.titleTextField.delegate = self;
    self.notesTextView.delegate = self;
    
    // Set the initial values of UI elements
    [self setInitialValues];
    
    // Set initial states of variables;
    self.recordWasModified = NO;
    self.saveChangesButton.enabled = NO;
    
    // Set up custom keyboard configurations
    [self setUpModifiedKeyboards];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setup

- (void)setInitialValues
{
    // Set initial values of the UI elements from the record being edited
    self.titleTextField.text = self.recordToEdit[@"title"];
    self.completionLabel.text = [NSString stringWithFormat:@"%@%%", self.recordToEdit[@"completed"]];
    [self.completionSlider setValue:[self.recordToEdit[@"completed"] floatValue]];
    [self.prioritySegmentedControl setSelectedSegmentIndex:[self.recordToEdit[@"priority"] integerValue]];
    
    self.deadline = self.recordToEdit[@"deadline"];
    
    if (self.deadline)
    {
        self.deadlineTextField.text = [self formattedStringFromDate:self.deadline];
    }
    
    self.notesTextView.text = self.recordToEdit[@"notes"];
}

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


#pragma mark - Navigation

- (IBAction)cancelEdit:(id)sender
{
    // Check if anything has been modified
    if (!self.recordWasModified)
    {
        // If nothing has changed return to list
        [self performSegueWithIdentifier:@"unwindToList" sender:self];
    }
    else
    {
        // If changes have been made prompt user
        UIAlertView *saveWarning = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You have unsaved changes. Do you wish to save the changes?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [saveWarning show];
    }
}

- (IBAction)saveChanges:(id)sender
{
    // Check the title is valid
    if (self.titleTextField.text.length < 1)
    {
        // Prompt user to enter a title
        UIAlertView *titleErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your entry must have a title." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [titleErrorAlert show];
    }
    else
    {
        // Save changes to the element
        [self updateRecord];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Remove observers
    [self.datastore removeObserver:self];
    
    // Close the datastore
    if (self.datastore)
    {
        [self.datastore close];
    }
    
    // Clear properties
    self.datastore = nil;
    self.recordToEdit = nil;
    self.deadline = nil;
}


#pragma mark - Keyboard Control

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Close keyboard when return key pressed
    [textField resignFirstResponder];
    return NO;
}

- (void)datePickerDone
{
    // Close the datepicker using done button on InputAccessory
    [self.deadlineTextField resignFirstResponder];
}

- (void)textViewDone
{
    // Close keyboard using done button on InputAccessory
    [self.notesTextView resignFirstResponder];
}


#pragma mark - Record Modification

- (IBAction)textFieldDidChange:(id)sender
{
    // Title is being modified
    // Enable Save Button
    self.recordWasModified = YES;
    self.saveChangesButton.enabled = YES;
}

- (IBAction)completionSliderChanged:(id)sender
{
    // Completion is being modified
    // Enable Save Button
    self.recordWasModified = YES;
    self.saveChangesButton.enabled = YES;
    
    // Update the label to reflect changes
    self.completionLabel.text = [NSString stringWithFormat:@"%@%%", [NSNumber numberWithInteger:self.completionSlider.value]];
}

- (IBAction)prioritySegmentedControllerChanged:(id)sender
{
    // Priority is being modified
    // Enable Save Button
    self.recordWasModified = YES;
    self.saveChangesButton.enabled = YES;
}

- (void)datePickerValueChanged: (UIDatePicker *)sender
{
    // Enable Save Button
    self.recordWasModified = YES;
    self.saveChangesButton.enabled = YES;
    
    // Update deadline field and store the date
    self.deadlineTextField.text = [self formattedStringFromDate:sender.date];
    self.deadline = sender.date;
}

- (IBAction)clearDeadline:(id)sender
{
    // Enable Save Button
    self.recordWasModified = YES;
    self.saveChangesButton.enabled = YES;
    
    // Clear deadline data
    self.deadlineTextField.text = @"";
    self.deadline = nil;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Notes are being modified
    // Enable Save Button
    self.recordWasModified = YES;
    self.saveChangesButton.enabled = YES;
    return YES;
}

- (IBAction)deleteTask:(id)sender
{
    // Delete the current task
    [self.recordToEdit deleteRecord];
    [self.datastore sync:nil];
}


#pragma mark - Updating Record

- (void)updateRecord
{
    // Update record with new values
    self.recordToEdit[@"title"] = self.titleTextField.text;
    self.recordToEdit[@"completed"] = [NSNumber numberWithInteger:self.completionSlider.value];
    self.recordToEdit[@"priority"] = [NSNumber numberWithInteger:self.prioritySegmentedControl.selectedSegmentIndex];
    if (self.deadline)
    {
        self.recordToEdit[@"deadline"] = self.deadline;
    }
    self.recordToEdit[@"notes"] = self.notesTextView.text;
    self.recordToEdit[@"modified"] = [NSDate date];
    
    // Sync the datastore
    [self.datastore sync:nil];
}

- (void)recordFinishedUpdating
{
    // Save has completed so return to the list
    [self performSegueWithIdentifier:@"unwindToList" sender:self];
}


#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Check the response from the user
    switch (buttonIndex)
    {
        case 0:
            // They wish to save changes
            [self saveChanges:(nil)];
            break;
            
        case 1:
            // They wish to discard changes
            [self performSegueWithIdentifier:@"unwindToList" sender:self];
            break;
            
        default:
            break;
    }
}


#pragma mark - Utilities

- (NSString *)formattedStringFromDate: (NSDate *)date
{
    // Create formatter
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yy HH:mm"];
    
    // Return formatted date
    return [dateFormat stringFromDate:date];
}

@end
