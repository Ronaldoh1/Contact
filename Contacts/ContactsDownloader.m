//
//  ContactsDownloader.m
//  Contacts
//
//  Created by Ronald Hernandez on 10/17/15.
//  Copyright © 2015 Solstice. All rights reserved.
//

#import "ContactsDownloader.h"

@implementation ContactsDownloader

//We want to pull the contacts information and store them in an array and provide it to the ParentVC (ContactListTVC)

-(void)downloadContactsFromEndPoint{

    //1. The first thing we need to do is to Create a URL from the api string.

    NSURL *url = [NSURL URLWithString:@"https://solstice.applauncher.com/external/contacts.json"];

    //2. Get items from Solstice API - create NSRURLSession (NSURLConnection has been deprecated for iOS9).

    NSURLSession *session = [NSURLSession sharedSession];

   [[session dataTaskWithURL:url completionHandler:^(NSData * data, NSURLResponse *  response, NSError *  error) {


       if (data != nil) {

           [self processData:data];
       }

  }] resume];

}

//Need to store all of the items in an array.
//We get back a dictionary of dictionary
-(void)processData:(NSData *)data{

    NSDictionary *contactsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    [self.delegate gotContacts:contactsDictionary];

}
@end
