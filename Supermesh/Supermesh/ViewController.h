//
//  ViewController.h
//  Supermesh
//
//  Created by Jamie Hoyle on 05/12/2015.
//  Copyright © 2015 Karambyte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaAsyncSocket.h"
#import "avcodec.h"

AsyncUdpSocket *UdpSocket;

// encoder context
AVCodec *en_codec;
AVCodecContext *en_context;

// decoder context
AVCodec *de_codec;
AVCodecContext *de_context;

@interface ViewController : UIViewController

@end