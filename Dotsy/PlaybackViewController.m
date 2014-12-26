//
//  PlaybackViewController.m
//  Dotsy
//
//  Created by Karl Grogan on 26/12/2014.
//  Copyright (c) 2014 Karl Grogan. All rights reserved.
//

#import "PlaybackViewController.h"

@interface PlaybackViewController ()

@end

@implementation PlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor whiteColor];
    
    
    // Setup our playback button.
    self.playPauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.playPauseButton.frame = CGRectMake(100, 100, 100, 100);
    [self.playPauseButton setTitle:@"Play/Pause" forState:UIControlStateNormal];
    
    /*
     * Setup our background artowrk image.
     * This block of code will create our UIImage based on the artwork on the atworkURL property.
     * Then it will create an UIImageView to allow us to interact with it. We can add buttons as subiviews to this view.
     */
    NSData *imgData = [NSData dataWithContentsOfURL:self.artworkURL];
    UIImage *backgroundArtworkImg = [UIImage imageWithData:imgData];
    UIImageView *backgroundArtworkView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundArtworkView.image = backgroundArtworkImg;
    [backgroundArtworkView setContentMode:UIViewContentModeScaleAspectFill];
    

    
    [self.playPauseButton addTarget:self action:@selector(playPausePlayback:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backgroundArtworkView];
    //[self.view addSubview:self.playPauseButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)playPausePlayback:(UIButton *)sender {
    if ([sender isEqual:self.playPauseButton]) {
        NSLog(@"Play puase button preseed.");
    }
}

@end
