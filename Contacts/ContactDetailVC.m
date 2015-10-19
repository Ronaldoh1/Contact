//
//  ContactDetailVCViewController.m
//  Contacts
//
//  Created by Ronald Hernandez on 10/18/15.
//  Copyright © 2015 Solstice. All rights reserved.
//

#import "ContactDetailVC.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MapKit/MapKit.h>
@interface ContactDetailVC ()<MFMailComposeViewControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *largeContactImage;

@property (weak, nonatomic) IBOutlet UITextField *workPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *homePhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *mobilePhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property NSDictionary *contactDetailDictionary;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property CGFloat animatedDistance;

@end
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
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
    titleView.text = self.contactToDisplay.name;
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = [UIColor orangeColor];
    [self.navigationItem setTitleView:titleView];


    //Update UI Elements
    self.nameTextField.text = self.contactToDisplay.name;
    self.companyNameTextField.text = self.contactToDisplay.companyName;
    self.workPhoneNumber.text = [self.contactToDisplay.phoneNumbersDict objectForKey:@"work"];
    self.homePhoneNumber.text = [self.contactToDisplay.phoneNumbersDict objectForKey:@"home"];
    self.mobilePhoneNumber.text =  [self.contactToDisplay.phoneNumbersDict objectForKey:@"mobile"];

    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSString *birthDateString = [myDateFormatter stringFromDate:self.contactToDisplay.birthdate];


    self.birthdayLabel.text = [NSString stringWithFormat:@"%@", birthDateString];
    [self downloadContactDetailsFromURL:self.contactToDisplay.detailsURL];


}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.contactToDisplay.name = self.nameTextField.text;
    self.contactToDisplay.companyName = self.companyNameTextField.text;
    self.contactToDisplay.phoneNumbersDict = @{@"work": self.workPhoneNumber.text, @"home": self.homePhoneNumber.text, @"mobile": self.mobilePhoneNumber.text};
    
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

    self.contactDetailDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];


    [self updateContactImageFromURL:[NSURL URLWithString:[self.contactDetailDictionary objectForKey:@"largeImageURL"]]];

    NSMutableDictionary *addressDict = [NSMutableDictionary new];

    addressDict = [self.contactDetailDictionary objectForKey:@"address"];
    self.addressLabel.text = [NSString stringWithFormat:@"%@\n%@, %@ %@",[addressDict objectForKey:@"street"], [addressDict objectForKey:@"city"],[addressDict objectForKey:@"state"],[addressDict objectForKey:@"zip"]];
    self.emailLabel.text =[NSString stringWithFormat:@"Email: %@", [self.contactDetailDictionary objectForKey:@"email"]];

    if ([[self.contactDetailDictionary objectForKey:@"favorite"] boolValue] == YES) {

        self.favoriteImage.alpha = 1.0;
    }


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

#pragma mark - Actions 
- (IBAction)onEditButtonTapped:(UIBarButtonItem *)sender {

    //we need to re-enable the user interaction for fields that we will let user edit. Change the border of the textfields to let the user know
    //where he/she can edit information.
    if ([self.editButton.title isEqualToString:@"Edit"]) {
        self.nameTextField.userInteractionEnabled = YES;
        self.companyNameTextField.userInteractionEnabled = YES;
        self.workPhoneNumber.userInteractionEnabled = YES;
        self.mobilePhoneNumber.userInteractionEnabled = YES;
        self.editButton.title = @"Done";

        self.nameTextField.borderStyle = UITextBorderStyleLine;
        self.companyNameTextField.borderStyle = UITextBorderStyleLine;
        self.workPhoneNumber.borderStyle = UITextBorderStyleLine;
        self.homePhoneNumber.borderStyle = UITextBorderStyleLine;
        self.mobilePhoneNumber.borderStyle = UITextBorderStyleLine;

    }else if ([self.editButton.title isEqualToString:@"Done"]) {

        self.nameTextField.borderStyle = UITextBorderStyleNone;
        self.companyNameTextField.borderStyle = UITextBorderStyleNone;
        self.workPhoneNumber.borderStyle = UITextBorderStyleNone;
        self.homePhoneNumber.borderStyle = UITextBorderStyleNone;
        self.mobilePhoneNumber.borderStyle = UITextBorderStyleNone;

        self.nameTextField.userInteractionEnabled = NO;
        self.companyNameTextField.userInteractionEnabled = NO;
        self.workPhoneNumber.userInteractionEnabled = NO;
        self.mobilePhoneNumber.userInteractionEnabled = NO;


        self.editButton.title = @"Edit";


    }

}

- (IBAction)onCallWorkPhoneButtonTapped:(UIButton *)sender {

    [self makeCallwithPhoneNumber:[self.contactToDisplay.phoneNumbersDict objectForKey:@"work"]];

}
- (IBAction)onCallHomePhoneButtonTapped:(UIButton *)sender {

    [self makeCallwithPhoneNumber:[self.contactToDisplay.phoneNumbersDict objectForKey:@"home"]];

}
- (IBAction)onCallMobilePhoneButtonTapped:(UIButton *)sender {

    [self makeCallwithPhoneNumber:[self.contactToDisplay.phoneNumbersDict objectForKey:@"mobile"]];
}
- (IBAction)onMapButtonTapped:(UIButton *)sender {

    NSDictionary *tempDict = [NSDictionary dictionaryWithDictionary:[self.contactDetailDictionary objectForKey:@"address"]];

    double longitude = [[tempDict objectForKey:@"latitude"] doubleValue];
    double latitude = [[tempDict objectForKey:@"longitude"] doubleValue];

    CLLocationCoordinate2D endingCoord = CLLocationCoordinate2DMake(longitude, latitude);
    MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:nil];
    MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];

    NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
    [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];

    [endingItem openInMapsWithLaunchOptions:launchOptions];

}

- (IBAction)onEmailButtonTapped:(UIButton *)sender {



    //allocate mail composer
    MFMailComposeViewController *composer = [MFMailComposeViewController new];
    //set the delegate
    [composer setMailComposeDelegate:self];

    //check if devise can send email

    if ([MFMailComposeViewController canSendMail]){
        [composer setToRecipients:[NSArray arrayWithObjects:[self.contactDetailDictionary objectForKey:@"email"], nil]];
        [composer setSubject:@"Subject"];
        [composer setMessageBody:@"Message Body" isHTML:NO];
        [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:composer animated:YES completion:nil];
    }

}

#pragma mark - Mail Delegate Method

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{

    //if there is no errror
    if (!error) {
        [self dismissViewControllerAnimated:YES completion:^{

            self.navigationItem.leftBarButtonItem.title = @"Cancel";
        }];

        //if there is an error we present an alert.
    } else {
        [self displayAlertWithTitle:@"Error Sending Email" andWithMessage:nil];
        [self dismissViewControllerAnimated:YES completion:nil];

    }
}
#pragma Helper Methods

-(void)makeCallwithPhoneNumber:(NSString *)phoneNumberString{

    NSString *phoneString = [NSString stringWithFormat:@"telprompt://%@",phoneNumberString];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneString]];


}
-(void)displayAlertWithTitle:(NSString *)title andWithMessage:(NSString *)message{


    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma Marks - hiding keyboard
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0){
        heightFraction = 0.0;
    }
    else if(heightFraction > 1.0){
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown){
        self.animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else{
        self.animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= self.animatedDistance;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];

    [self.view setFrame:viewFrame];

    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textfield{

    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += self.animatedDistance;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];

    [self.view setFrame:viewFrame];

    [UIView commitAnimations];
}
////hide keyboard when the user clicks return
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];

    [self.view endEditing:true];
    return true;
}
//hide keyboard when user touches outside.
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}



@end
