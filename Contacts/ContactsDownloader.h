//
//  ContactsDownloader.h
//  Contacts
//
//  Created by Ronald Hernandez on 10/17/15.
//  Copyright © 2015 Solstice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol ContactsDownloaderDelegate <NSObject>

-(void)gotContacts:(NSDictionary *)dictionary;

@end

@interface ContactsDownloader : NSObject

@property NSString *apString;

//objects the current class have a delegate that can be of any type (id) but must conform to the ContactsDownloader protocol. The class containing delegate knows that there are specific messages tha ti can send to its delegate and know that the delegate will respond  to them. 
@property id<ContactsDownloaderDelegate>delegate;

-(void)downloadContactsFromEndPoint;

@end
