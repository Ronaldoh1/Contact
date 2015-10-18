//
//  ContactsDownloader.h
//  Contacts
//
//  Created by Ronald Hernandez on 10/17/15.
//  Copyright © 2015 Solstice. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContactsDownloaderDelegate <NSObject>

-(void)gotContacts:(NSArray *)array;

@end

@interface ContactsDownloader : NSObject

@property NSString *apString;
@property id<ContactsDownloaderDelegate>ParentVC;

-(void)downloadContactsFromEndPoint;

@end
