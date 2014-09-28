//
//  ToDoTests.m
//  ToDoTests
//
//  Created by James Gilmartin on 25/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HomeViewController.h"
#import "ItemListViewController.h"
#import "AddNewTaskViewController.h"
#import "EditTaskViewController.h"

@interface ToDoTests : XCTestCase

@end

@implementation ToDoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - Home View Controller Tests

- (void)testDateWithoutTimeComponent
{
    HomeViewController *hvc = [[HomeViewController alloc] init];
    
    NSDateComponents *comps1 = [[NSDateComponents alloc] init];
    [comps1 setDay:30];
    [comps1 setMonth:01];
    [comps1 setYear:1979];
    [comps1 setHour:17];
    [comps1 setMinute:30];
    NSDate *date1 = [[NSCalendar currentCalendar] dateFromComponents:comps1];
    
    NSDateComponents *comps2 = [[NSDateComponents alloc] init];
    [comps2 setDay:30];
    [comps2 setMonth:01];
    [comps2 setYear:1979];
    [comps2 setHour:11];
    [comps2 setMinute:25];
    NSDate *date2 = [[NSCalendar currentCalendar] dateFromComponents:comps2];
    
    date1 = [hvc dateWithoutTimeComponents:date1];
    date2 = [hvc dateWithoutTimeComponents:date2];
    
    XCTAssertEqual(date1.timeIntervalSince1970, date2.timeIntervalSince1970, @"Dates are the same");
}


#pragma mark - Item List View Controller Tests

- (void)testColourForPriorityLow
{
    ItemListViewController *ilvc = [[ItemListViewController alloc] init];
    
    UIColor *result = [ilvc getColourForPriority:0];
    
    XCTAssertEqualObjects(result, [UIColor colorWithRed:(45.0/255.0) green:(144.0/255.0) blue:(68.0/255.0) alpha:1], @"Colours are the same");
}

- (void)testColourForPriorityMedium
{
    ItemListViewController *ilvc = [[ItemListViewController alloc] init];
    
    UIColor *result = [ilvc getColourForPriority:1];
    
    XCTAssertEqualObjects(result, [UIColor colorWithRed:(216.0/255.0) green:(92.0/255.0) blue:(39.0/255.0) alpha:1], @"Colours are the same");
}

- (void)testColourForPriorityHigh
{
    ItemListViewController *ilvc = [[ItemListViewController alloc] init];
    
    UIColor *result = [ilvc getColourForPriority:2];
    
    XCTAssertEqualObjects(result, [UIColor colorWithRed:(201.0/255.0) green:(32.0/255.0) blue:(55.0/255.0) alpha:1], @"Colours are the same");
}

- (void)testPastTimeStringForDeadline
{
    ItemListViewController *ilvc = [[ItemListViewController alloc] init];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:30];
    [comps setMonth:01];
    [comps setYear:1979];
    [comps setHour:11];
    [comps setMinute:25];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    NSString *formattedDate = [ilvc formattedStringFromDate:date forModified:NO];
    
    XCTAssertEqualObjects(formattedDate, @"Deadline Passed", @"Date in the past formatted correctly");
}

- (void)testPastTimeStringForModified
{
    ItemListViewController *ilvc = [[ItemListViewController alloc] init];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:30];
    [comps setMonth:01];
    [comps setYear:1979];
    [comps setHour:11];
    [comps setMinute:25];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    NSString *formattedDate = [ilvc formattedStringFromDate:date forModified:YES];
    
    XCTAssertEqualObjects(formattedDate, @"30/01/79 11:25", @"Date in the past formatted correctly");
}

- (void)testTodayStringForDeadline
{
    ItemListViewController *ilvc = [[ItemListViewController alloc] init];
    
    NSDate *date = [NSDate date];
    
    NSString *formattedDate = [ilvc formattedStringFromDate:date forModified:NO];
    
    NSArray *splitString = [formattedDate componentsSeparatedByString:@" "];
    NSString *dayElement = [splitString objectAtIndex:0];
    
    XCTAssertEqualObjects(dayElement, @"Today", @"Todays date formatted correctly");
}

- (void)testTodayStringForModified
{
    ItemListViewController *ilvc = [[ItemListViewController alloc] init];
    
    NSDate *date = [NSDate date];
    
    NSString *formattedDate = [ilvc formattedStringFromDate:date forModified:YES];
    
    NSArray *splitString = [formattedDate componentsSeparatedByString:@" "];
    NSString *dayElement = [splitString objectAtIndex:0];
    
    XCTAssertEqualObjects(dayElement, @"Today", @"Todays date formatted correctly");
}

- (void)testTomorrowStringForDeadline
{
    ItemListViewController *ilvc = [[ItemListViewController alloc] init];
    
    NSDate *date = [NSDate date];
    date = [date dateByAddingTimeInterval:86400];
    
    NSString *formattedDate = [ilvc formattedStringFromDate:date forModified:NO];
    
    NSArray *splitString = [formattedDate componentsSeparatedByString:@" "];
    NSString *dayElement = [splitString objectAtIndex:0];
    
    XCTAssertEqualObjects(dayElement, @"Tomorrow", @"Todays date formatted correctly");
}

- (void)testFutureStringForDeadline
{
    ItemListViewController *ilvc = [[ItemListViewController alloc] init];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:30];
    [comps setMonth:01];
    [comps setYear:2016];
    [comps setHour:11];
    [comps setMinute:25];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    NSString *formattedDate = [ilvc formattedStringFromDate:date forModified:YES];
    
    XCTAssertEqualObjects(formattedDate, @"30/01/16 11:25", @"Date in the future formatted correctly");
}


#pragma mark - UIView+FindFirstResponder Tests

- (void)testForFirstResponderIfNewTaskTitleField
{
    AddNewTaskViewController *vc = [[AddNewTaskViewController alloc] init];
    
    [vc.titleTextField becomeFirstResponder];
    
    id textInput = [vc.view findFirstResponder];
    
    XCTAssertEqual(textInput, vc.titleTextField, @"Title Field is active");
}

- (void)testForFirstResponderIfNewTaskDeadlineField
{
    AddNewTaskViewController *vc = [[AddNewTaskViewController alloc] init];
    
    [vc.deadlineTextField becomeFirstResponder];
    
    id textInput = [vc.view findFirstResponder];
    
    XCTAssertEqual(textInput, vc.deadlineTextField, @"Deadline Field is active");
}

- (void)testForFirstResponderIfNewTaskNotesView
{
    AddNewTaskViewController *vc = [[AddNewTaskViewController alloc] init];
    
    [vc.notesTextView becomeFirstResponder];
    
    id textInput = [vc.view findFirstResponder];
    
    XCTAssertEqual(textInput, vc.notesTextView, @"Notes View is active");
}

- (void)testForFirstResponderIfEditTaskTitleField
{
    EditTaskViewController *vc = [[EditTaskViewController alloc] init];
    
    [vc.titleTextField becomeFirstResponder];
    
    id textInput = [vc.view findFirstResponder];
    
    XCTAssertEqual(textInput, vc.titleTextField, @"Title Field is active");
}

- (void)testForFirstResponderIfEditTaskDeadlineField
{
    EditTaskViewController *vc = [[EditTaskViewController alloc] init];
    
    [vc.deadlineTextField becomeFirstResponder];
    
    id textInput = [vc.view findFirstResponder];
    
    XCTAssertEqual(textInput, vc.deadlineTextField, @"Deadline Field is active");
}

- (void)testForFirstResponderIfEditTaskNotesView
{
    EditTaskViewController *vc = [[EditTaskViewController alloc] init];
    
    [vc.notesTextView becomeFirstResponder];
    
    id textInput = [vc.view findFirstResponder];
    
    XCTAssertEqual(textInput, vc.notesTextView, @"Notes View is active");
}

@end
