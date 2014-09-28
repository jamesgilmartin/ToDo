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
    
    // Store the original center in order to reset view when keyboard closes.
    self.originalCenter = self.view.center;
    
    // Open the datastore
    self.datastore = [[DBDatastoreManager sharedManager] openDefaultDatastore:nil];
    
    // Set delegates for text elements
    self.titleTextField.delegate = self;
    self.notesTextView.delegate = self;
    
    // Set the initial values of UI elements
    [self setInitialValues];
    
    // Set up custom keyboard configurations
    [self setUpModifiedKeyboards];
    
    // Listen for keyboard actions
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Set Navigation bar buttons to be white
    [self.navigationController navigationBar].tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
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

- (void)keyboardWillShow: (NSNotification *)notification
{
    // Get the size of the keyboard
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Check which object is the first responder
    if ([self.view findFirstResponder] == self.deadlineTextField)
    {
        // Check if the object is hidden by the keyboard
        int relativePositionToKeyboardTop = (self.view.bounds.size.height - kbSize.height) - (self.deadlineTextField.frame.origin.y + self.deadlineTextField.bounds.size.height);
        
        if (relativePositionToKeyboardTop < 0)
        {
            // Object is hidden so move the view
            [self moveViewUp: relativePositionToKeyboardTop];
        }
    }
    else if ([self.view findFirstResponder] == self.notesTextView)
    {
        // Check if the object is hidden by the keyboard
        int relativePositionToKeyboardTop = (self.view.bounds.size.height - kbSize.height) - (self.notesTextView.frame.origin.y + self.notesTextView.bounds.size.height);
        
        if (relativePositionToKeyboardTop < 0)
        {
            // Object is hidden so move the view
            [self moveViewUp: relativePositionToKeyboardTop];
        }
    }
}

- (void)moveViewUp: (int)distance
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         // Move the view up in order to reveal the first responder
                         self.view.center = CGPointMake(self.view.center.x, self.view.center.y + distance - 20);
                     }
                     completion:^(BOOL finished){}];
}

- (void)keyboardWillHide: (NSNotification *)notification
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         // Reset the view to its original position
                         self.view.center = self.originalCenter;
                     }
                     completion:^(BOOL finished){}];
}


#pragma mark - Record Modification

- (IBAction)textFieldFinishedEditing:(id)sender
{
    [self updateRecord];
}

- (IBAction)completionSliderChanged:(id)sender
{
    // Update the label to reflect changes
    self.completionLabel.text = [NSString stringWithFormat:@"%@%%", [NSNumber numberWithInteger:self.completionSlider.value]];
    [self updateRecord];
}

- (IBAction)prioritySegmentedControllerChanged:(id)sender
{
    [self updateRecord];
}

- (void)datePickerValueChanged: (UIDatePicker *)sender
{
    // Update deadline field and store the date
    self.deadlineTextField.text = [self formattedStringFromDate:sender.date];
    self.deadline = sender.date;
    [self updateRecord];
}

- (IBAction)clearDeadline:(id)sender
{
    // Clear deadline data
    self.deadlineTextField.text = @"";
    self.deadline = nil;
    [self updateRecord];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateRecord];
}

- (IBAction)deleteTask:(id)sender
{
    // Delete the current task
    [self.recordToEdit deleteRecord];
    [self.datastore sync:nil];
    
    [self performSegueWithIdentifier:@"unwindToList" sender:self];
}


#pragma mark - Updating Record

- (void)updateRecord
{
    // Update record with new values
    self.recordToEdit[@"title"] = self.titleTextField.text;
    self.recordToEdit[@"completed"] = [NSNumber numberWithInteger:self.completionSlider.value];
    if ((int)self.completionSlider.value == 100)
    {
        self.recordToEdit[@"completedBOOL"] = @YES;
    }
    else
    {
        self.recordToEdit[@"completedBOOL"] = @NO;
    }
    self.recordToEdit[@"priority"] = [NSNumber numberWithInteger:self.prioritySegmentedControl.selectedSegmentIndex];
    if (self.deadline)
    {
        self.recordToEdit[@"deadline"] = self.deadline;
        self.recordToEdit[@"hasDeadline"] = @YES;
        self.recordToEdit[@"roundedDeadline"] = [self dateWithoutTimeComponents:self.deadline];
    }
    else
    {
        self.recordToEdit[@"hasDeadline"] = @NO;
    }
    self.recordToEdit[@"notes"] = self.notesTextView.text;
    self.recordToEdit[@"modified"] = [NSDate date];
    
    // Sync the datastore
    [self.datastore sync:nil];
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

- (NSDate *)dateWithoutTimeComponents: (NSDate *)date
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    return [calendar dateFromComponents:[calendar components:preservedComponents fromDate:date]];
}

@end
