//
//  SoundCloudTableViewController.m
//  Dotsy
//
//  Created by Karl Grogan on 02/11/2014.
//  Copyright (c) 2014 Karl Grogan. All rights reserved.
//

#import "SoundCloudTableViewController.h"
#import "SCUI.h"
#import "PlaybackViewController.h"


@interface SoundCloudTableViewController ()

@end

@implementation SoundCloudTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"1 -- Scanning for Chromecast devices.");
    
    /*
     * Initialize Chromecast device scanner
     * Set this controller instance as the one to listen.
     * Start scanning for Chromecast devices.
     */
    self.deviceScanner = [[GCKDeviceScanner alloc] init];
    [self.deviceScanner addListener:self];
    [self.deviceScanner startScan];
    
    NSLog(@"1.1 -- Creating Soundcloud login completion handler.");
    
    /*
     * This ia completion handler is fired when the user successfully logs in to their Soundcloud account.
     */
    SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Soundcloud login canceled.");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Soundcloud login successful.");
            NSLog(@"Creating request to pull back Soundcloud favorites.");
            
            [SCRequest performMethod:SCRequestMethodGET
                          onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me/favorites.json"]
                     usingParameters:nil
                         withAccount:[SCSoundCloud account]
              sendingProgressHandler:nil
                     responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                            NSLog(@"Inside response handler for the Soundcloud favorites request.");
                         
                            // Serialize the JSON response.
                            NSJSONSerialization *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            self.tracks = (NSArray *)jsonResponse;
                            // We need to reload the data in the table to display the changes (the track favorites returned in our repsonse.)
                            [self.tableView reloadData];
            }];
        }
    };
    
    NSLog(@"1.2 -- Created Soundcloud login completion handler.");
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        /* 
         * Create the Soundcloud login view controller.
         * Present the login controller with a modal view.
         */
        SCLoginViewController *loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL completionHandler:handler];
        [self presentModalViewController:loginViewController animated:YES];
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.tracks.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Track"];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Track"];
        cell.textLabel.text = [self.tracks objectAtIndex:indexPath.row][@"title"];
        cell.detailTextLabel.text = [self.tracks objectAtIndex:indexPath.row][@"user"][@"username"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"8 -- Song cell was selected");
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    NSLog(@"8.1 -- %@", [track description]);
    // Get the streaming URL so we can actually stream the song!
    NSString *streamURL = [track objectForKey:@"stream_url"];
    NSLog(@"8.2 -  %@", streamURL);
    
    NSLog(@"8.3 -- Creating request to stream the track.");
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:streamURL]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                 NSLog(@"9 -- Inside the response handler for the stream request.");
                 NSLog(@"%@", [response description]);
                 NSLog(@"10 -- Creating metadata.");
                 
                 /*
                  * GCKMediaMetadata is a class that just adds some descriptive information for the media being played on the Chromecast.
                  */
                 GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
                 [metadata setString:track[@"title"] forKey:kGCKMetadataKeyTitle];
                 [metadata setString:track[@"user"][@"username"] forKey:kGCKMetadataKeySubtitle];
                 
                 // track[@"artwork_url"] is a NSString object so we need to create an NSURL object for this to work.
                 // Even if you don't it doesn't seem to throw an error.
                 
                 /*
                  * The default artwork URL Soundcloud givues is not the high resolution one wewant.
                  * To retrieve the high resolution image we need to change the artowrk_url by replacing the 'large' substring with 't500x500'
                 */
                 NSString *artWorkURL = track[@"artwork_url"];
                 NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"large" options:NSRegularExpressionCaseInsensitive error:nil];
                 NSString *hiResArtWorkURL = [regex stringByReplacingMatchesInString:artWorkURL options:0 range:NSMakeRange(0, [artWorkURL length]) withTemplate:@"t500x500"];
                 NSLog(@"10 -- High resolution artowrk URL: %@", hiResArtWorkURL);
                 
                 [metadata addImage:[[GCKImage alloc] initWithURL:[[NSURL alloc] initWithString:hiResArtWorkURL] width:100 height:100]];

                 // Since the response type is of NSURLResponse we need to cast it to NSHTTPURLResponse because that contains header information we need to access.
                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;

                 // Just some logging.
                 NSLog(@"%@", response.MIMEType);
                 NSLog(@"%@", httpResponse.allHeaderFields);
                 NSLog(@"%i", [httpResponse.allHeaderFields[@"x-amz-meta-duration"] integerValue]);

                 /*
                  * This allows the media to be cast on the media control channel.
                  * GCKMediaInformation is the class the model's a media item that is used by the Chromecast.
                  */
                 GCKMediaInformation *mediaInformation =
                 [[GCKMediaInformation alloc] initWithContentID:[response.URL absoluteString]
                                                     streamType:GCKMediaStreamTypeNone
                                                    contentType:response.MIMEType
                                                       metadata:metadata
                                                 streamDuration:[httpResponse.allHeaderFields[@"x-amz-meta-duration"] integerValue]
                                                     customData:nil];
                 
                 NSLog(@"MediaInformation");
                 NSLog(@"%@", [mediaInformation description]);
    
                 // Use the media control channel created when the media receiver application launched to load the media onto the Chromecast.
                 // This will begin casting the track on the Chromecast.
                 //[self.mediaControlChannel loadMedia:mediaInformation autoplay:TRUE playPosition:0];
                 
                 PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
                 playbackViewController.mediaControlChannel = self.mediaControlChannel;
                 playbackViewController.artworkURL = [[NSURL alloc] initWithString:hiResArtWorkURL];
                 playbackViewController.playing = YES;
                 [self.navigationController pushViewController:playbackViewController animated:TRUE];
             }];
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

#pragma mark - GCKDeviceScannerListener

- (void)deviceDidComeOnline:(GCKDevice *)device {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    
    NSLog(@"2 -- Chromecast device found.");
    NSLog(@"3 -- Connecting to the device");

    // Since the Chromecast is online, create the device manager.
    self.deviceManager = [[GCKDeviceManager alloc] initWithDevice:self.deviceScanner.devices[0]
                                                clientPackageName:[info objectForKey:@"CFBundleIdentifier"]];
    
    // Set the device manager delegate to the instance of this controller.
    self.deviceManager.delegate = self;
    [self.deviceManager connect];
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
    NSLog(@"4 -- Chromecast device went offline.");
}

#pragma mark - GCKDeviceManagerDelegate

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
    NSLog(@"5 -- Connected to Google Chromecast.");
    NSLog(@"6 -- Launching application with default media receiver application ID.");
    [self.deviceManager launchApplication:kGCKMediaDefaultReceiverApplicationID];
    NSLog(@"6.1 -- Launched application with default media receiver application ID.");
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApplication {
    
    NSLog(@"7 -- Connected to Chromecast media cast receiver application");
    
    // Create a media control channel to allow us to play, pause, and stop the media on the receiver application.
    self.mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    self.mediaControlChannel.delegate = self;
    [self.deviceManager addChannel:self.mediaControlChannel];
    [self.mediaControlChannel requestStatus];
}

@end
