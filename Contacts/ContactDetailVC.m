//
//  ContactDetailVCViewController.m
//  Contacts
//
//  Created by Ronald Hernandez on 10/18/15.
//  Copyright © 2015 Solstice. All rights reserved.
//

#import "ContactDetailVC.h"

@interface ContactDetailVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *largeContactImage;


@end

@implementation ContactDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Make Large Contact Image Circular
    self.largeContactImage.layer.cornerRadius = self.largeContactImage.frame.size.height / 2;
    self.largeContactImage.layer.masksToBounds = YES;
    self.largeContactImage.layer.borderWidth = 3.0;
    self.largeContactImage.layer.borderColor = [UIColor orangeColor].CGColor;

    // Add titleView to NavBar
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    titleView.font = [UIFont fontWithName:@"Helvetica Bold" size:22];
    titleView.text = @"Contacts";
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = [UIColor orangeColor];
    [self.navigationItem setTitleView:titleView];



    self.nameTextField.text = self.contactToDisplay.name;
    self.companyNameTextField.text = self.contactToDisplay.companyName;

    [self downloadContactDetailsFromURL:self.contactToDisplay.detailsURL];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//We want to pull the contacts information and store them in an array and provide it to the ParentVC (ContactListTVC)

-(void)downloadContactDetailsFromURL:(NSURL *)url{

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
//use the information from dictionary to update the UI Elements 
-(void)processData:(NSData *)data{

    NSDictionary *contactDetailDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];


    NSMutableArray *InfoArray = [NSMutableArray new];


        for (NSDictionary *tempDict in contactDetailDictionary) {
    
            [InfoArray addObject:tempDict];
        }

    NSLog(@"%@",contactDetailDictionary);

    [self updateContactImageFromURL:[NSURL URLWithString:[contactDetailDictionary objectForKey:@"largeImageURL"]]];
    
}

-(void)updateContactImageFromURL:(NSURL *)imageURL{


    //Get the contact image
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSData *largeImageData = [NSData dataWithContentsOfURL:imageURL];



        if (largeImageData != nil) {
            //Update the UI on the main thread - set the cell's contact image to image retrieved.

            UIImage *image = [UIImage imageWithData:largeImageData];

            dispatch_sync(dispatch_get_main_queue(), ^{

                [UIView animateWithDuration:0.5 animations:^{


                    self.largeContactImage.image = image;
                }];

            });

        }
        
        
    });
}


@end
