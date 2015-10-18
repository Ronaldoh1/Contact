//
//  Contact.h
//  Contacts
//
//  Created by Ronald Hernandez on 10/17/15.
//  Copyright © 2015 Solstice. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property NSString *name;
@property NSInteger employeeId;
@property NSString *companyName;
@property NSURL *detailsURL;
@property NSURL *smallImageURL;
@property NSURL *largeImageURL;
@property NSDate *birthdate;
@property NSDictionary *phoneNumbersDict;
@property UIImage *smallContactImage;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
