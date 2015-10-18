//
//  ContactListTVC.m
//  Contacts
//
//  Created by Ronald Hernandez on 10/17/15.
//  Copyright © 2015 Solstice. All rights reserved.
//

#import "ContactListTVC.h"
#import "ContactsDownloader.h"
#import "Contact.h"
#import "ContactCustomCell.h"

@interface ContactListTVC ()<ContactsDownloaderDelegate>

@property ContactsDownloader *downloader;
@property NSMutableArray *contactsArray;

@end

static NSString *const cellIdentifier = @"contactCell";

@implementation ContactListTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // hange the Nav Title and set it to white.
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    titleView.font = [UIFont fontWithName:@"Helvetica Bold" size:22];
    titleView.text = @"Contacts";
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = [UIColor orangeColor];
    [self.navigationItem setTitleView:titleView];

    //allocate and initialize array to hold Contacts
    self.contactsArray = [NSMutableArray new];

    self.downloader = [ContactsDownloader new];
    self.downloader.delegate = self;
    [self.downloader downloadContactsFromEndPoint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Downloader Delegate

-(void)gotContacts:(NSDictionary *)dictionary{

    for (NSDictionary *dict in dictionary) {

        Contact *contact = [[Contact alloc]initWithDictionary:dict];
        [self.contactsArray addObject:contact];
    }

    [self.tableView reloadData];
}

#pragma mark - Table view data source
//Number of sections to display.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//Number of rows to display in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactsArray.count;
}

#pragma mark - Table view delegate methods 

//In thisc cellForRowAtIndexPath: we are basically pupulating each cell with the appropriate deatails for each contact with name, image phone number etc. To propertly load the images and avoid visual bugs (wrong image displayed when scrolling), we need to reset the last image for the dequeued cell - otherwise it might still be there. Another problem solved is that asynchonous request might not be finished before the cell scrolls off the screen. This will ensure that we dont accidentaly update the contact image for a row that has scrolled off the screen. 
- (ContactCustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //initialize the cell
    ContactCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[ContactCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    cell.smallContactImage.image = nil;

    //create a contact for each object in the array.
    Contact *contact = (Contact *)self.contactsArray[indexPath.row];

    //Get the contact image
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSData *smallImageData = [NSData dataWithContentsOfURL:contact.smallImageURL];



            if (smallImageData != nil) {
                //Update the UI on the main thread - set the cell's contact image to image retrieved.

                UIImage *image = [UIImage imageWithData:smallImageData];
                dispatch_sync(dispatch_get_main_queue(), ^{

                    ContactCustomCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                    

                updateCell.smallContactImage.alpha = 0.0;
                [UIView animateWithDuration:0.5 animations:^{


                    updateCell.smallContactImage.alpha = 1.0;

                    updateCell.smallContactImage.image = image;
                }];

             });

            }else{
                cell.smallContactImage.image = [UIImage imageNamed:@"defaultImage.png"];
            }



    });

    //populate the cell
    cell.nameLabel.text = contact.name;
    cell.phoneNumberLabel.text = [contact.phoneNumbersDict objectForKey:@"work"];
    

    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//Helper Methods to display alert to user.

-(void)displayAlertMessage:(NSString *)title andWith:(NSString *)message{

    //1. Create a UIAlertController

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    //2. Create a UIAlertController to be added to the alert.

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];

    //3. Add the action to the controller.
    [alertController addAction:okAction];


    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}

@end
