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
    
    // Store the original center in order to reset view when keyboard closes.
    self.originalCenter = self.view.center;
    
    // Set delegates
    self.titleTextField.delegate = self;
    self.notesTextView.delegate = self;
    
    // Set initial value for completion label
    self.completionLabel.text = @"0%";
    
    // Setup required Keyboards for various fields
    [self setUpModifiedKeyboards];
    
    // Initially disable save button
    self.saveButton.enabled = NO;
    
    // Listen for keyboard actions
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Set Navigation bar buttons to be white
    [self.navigationController navigationBar].tintColor = [UIColor whiteColor];
    
    // Disable gestures
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setup

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

- (IBAction)cancelNewTask:(id)sender
{
    // Return to the table view controller
    [self performSegueWithIdentifier:@"unwindToList" sender:self];
}

- (IBAction)saveNewTask:(id)sender
{
    [self saveRecord];
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

- (IBAction)textFieldDidChange:(id)sender
{
    // Save button enabled only if the new element has a title
    if (self.titleTextField.text.length > 0)
    {
        self.saveButton.enabled = YES;
    }
    else
    {
        self.saveButton.enabled = NO;
    }
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

- (IBAction)clearDeadline:(id)sender
{
    // Clear deadline field and nullify the stored date
    self.deadlineTextField.text = @"";
    self.deadline = nil;
}


#pragma mark - Saving Record

- (void)saveRecord
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
    if ((int)[NSNumber numberWithInteger:self.completionSlider.value] == 100)
    {
        [itemValues setObject:@YES forKey:@"completedBOOL"];
    }
    else
    {
        [itemValues setObject:@NO forKey:@"completedBOOL"];
    }
    [itemValues setObject:[NSNumber numberWithInteger:self.prioritySegmentedControl.selectedSegmentIndex] forKey:@"priority"];
    if (self.deadline)
    {
        [itemValues setObject:self.deadline forKey:@"deadline"];
        [itemValues setObject:@YES forKey:@"hasDeadline"];
        [itemValues setObject:[self dateWithoutTimeComponents:self.deadline] forKey:@"roundedDeadline"];
    }
    else
    {
        [itemValues setObject:@NO forKey:@"hasDeadline"];
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
    self.deadline = nil;
    
    // Return to the table view controller
    [self performSegueWithIdentifier:@"unwindToList" sender:self];
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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

@end
