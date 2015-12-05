//
//  ViewController.m
//  Supermesh
//
//  Created by Jamie Hoyle on 05/12/2015.
//  Copyright © 2015 Karambyte. All rights reserved.
//

#import "ViewController.h"
#import "CocoaAsyncSocket.h"
#import "avcodec.h"

#define INBUF_SIZE 4096

@interface ViewController ()

@end

@implementation ViewController

// set up method to decode frame
static int decode_write_frame(const char *outfilename, AVCodecContext *avctx, AVFrame *frame, AVPacket *pkt, int last) {
    
    int len, got_frame;
    char buf[1024];
    
    len = avcodec_decode_video2(avctx, frame, &got_frame, pkt);
    if(len < 0) {
        // decoding failed
    }
    if(got_frame) {
        // we have the frame
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // register ALL the avcodec bits and pieces
    avcodec_register_all();
    
    // Do any additional setup after loading the view, typically from a nib.
    UdpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    if (![UdpSocket bindToPort:21369 error:nil])
        NSLog(@"Bind error");
    [UdpSocket receiveWithTimeout:-1 tag:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data
           withTag:(long)tag
          fromHost:(NSString *)host
              port:(UInt16)port
{
    NSLog(@"Received UDP Packet");
    
    // deal with the data, put into libav
    int got_picture, len;
    
    AVFrame *frame;
    uint8_t inbuf[INBUF_SIZE + FF_INPUT_BUFFER_PADDING_SIZE];
    char buf[1024];
    
    // set up packet and configure
    AVPacket avpkt;
    av_init_packet(&avpkt);
    
    // avoid overriding
    memset(inbuf + INBUF_SIZE, 0, FF_INPUT_BUFFER_PADDING_SIZE);
    
    de_codec = avcodec_find_encoder(CODEC_ID_MP4ALS);
    if(!de_codec) {
        NSLog(@"We screwed up, this codec isn't available");
        exit(1);
    }
    
    // allocate the context with the specified codec
    de_context = avcodec_alloc_context3(de_codec);
    
    frame = avcodec_alloc_frame();
    avpkt.data = inbuf;
    while(avpkt.size > 0) {
        if(decode_write)
    }
    
    // send the encoded data back to the server
    UInt8 *bytes = (UInt8 *)data.bytes;
    if (data.length >= 4)
        NSLog(@"Byte0: %d, Byte1: %d, Byte2: %d, Byte3: %d", bytes[0], bytes[1], bytes[2], bytes[3]);
    
    //TX RESPONSE
    UInt8 TxDataBytes[10];
    int TxDataIndex = 0;
				
    TxDataBytes[TxDataIndex++] = 0x01;
    TxDataBytes[TxDataIndex++] = 0x02;
    TxDataBytes[TxDataIndex++] = 0x03;
    TxDataBytes[TxDataIndex++] = 0x04;
    
    NSData *TxData = [NSData dataWithBytes:&TxDataBytes length:TxDataIndex];
				
    [UdpSocket sendData:TxData
                  toHost:host
                    port:1234
             withTimeout:2.0		//Seconds
                     tag:0];
    
    
    [UdpSocket receiveWithTimeout:-1 tag:1];			//Setup to receive next UDP packet
    return YES;			//Signal that we didn't ignore the packet.
}

@end
