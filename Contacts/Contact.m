//
//  Contact.m
//  Contacts
//
//  Created by Ronald Hernandez on 10/17/15.
//  Copyright © 2015 Solstice. All rights reserved.
//

#import "Contact.h"

@implementation Contact

/* We need to initialize the object's properties with the values obtained from each dictionary in our API Call. Here we also need to convert each property of the product to  their correct data type.
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{

    self = [super self];

    self.name = [dictionary objectForKey:@"name"];



    return self;
}

@end
