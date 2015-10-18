//
//  ContactCustomCell.m
//  Contacts
//
//  Created by Ronald Hernandez on 10/17/15.
//  Copyright © 2015 Solstice. All rights reserved.
//

#import "ContactCustomCell.h"

@implementation ContactCustomCell

- (void)awakeFromNib {
    // Initialization code
    //Here we want to change the look of the small image and make it circular. We will also add a border thin border to give it the look and feel some personality.

    self.smallContactImage.layer.cornerRadius = self.smallContactImage.frame.size.height / 2;
    self.smallContactImage.layer.masksToBounds = YES;
    self.smallContactImage.layer.borderWidth = 3.0;
    self.smallContactImage.layer.borderColor = [UIColor orangeColor].CGColor;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onMakeCallButtonTapped:(id)sender {
}

@end
