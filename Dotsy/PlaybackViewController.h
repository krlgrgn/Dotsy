//
//  PlaybackViewController.h
//  Dotsy
//
//  Created by Karl Grogan on 26/12/2014.
//  Copyright (c) 2014 Karl Grogan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GoogleCast/GoogleCast.h>

@interface PlaybackViewController : UIViewController

@property (nonatomic, strong) GCKMediaControlChannel *mediaControlChannel;

@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) NSURL *artworkURL;
@property BOOL playing;

@end
