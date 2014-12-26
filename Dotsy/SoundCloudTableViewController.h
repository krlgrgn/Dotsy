//
//  SoundCloudTableViewController.h
//  Dotsy
//
//  Created by Karl Grogan on 02/11/2014.
//  Copyright (c) 2014 Karl Grogan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GoogleCast/GoogleCast.h>

@interface SoundCloudTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) GCKDeviceScanner *deviceScanner;
@property (nonatomic, strong) GCKDeviceManager *deviceManager;
@property (nonatomic, strong) GCKMediaControlChannel *mediaControlChannel;

@end
