//
//  ViewController.m
//  OpenGL-Tutorial
//
//  Created by Mahfuz on 16/2/20.
//  Copyright © 2020 KITE GAMES STUDIO. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic) NSTimer *timer;

@end


@implementation ViewController
{
    int count;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    //self performSelector:nil withObject:<#(nullable id)#> afterDelay: ];
    [self updateTimer];
}

- (void) updateTimer {
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateFrame: )
                                                userInfo:nil
                                                 repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) updateFrame: (NSTimer*)timer {
    
    //NSString *currentTime = self.timer.fireDate.description;
    
    count++;
    if(count == 15)
    {
        [self.timer invalidate];
        NSLog(@"[self.timer invalidate]; ========== ");
    }

    [self.glView update];
}

@end
