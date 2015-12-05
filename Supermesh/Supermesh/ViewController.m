//
//  ViewController.m
//  Supermesh
//
//  Created by Jamie Hoyle on 05/12/2015.
//  Copyright © 2015 Karambyte. All rights reserved.
//

#import "ViewController.h"
#import <CFNetwork/CFNetwork.h>
#import "CocoaAsyncSocket.h"
#import "avcodec.h"

#define INBUF_SIZE 4096

@interface ViewController ()

@end

@implementation ViewController

// set up method to decode frame
static int decode_write_frame(const char *outfilename, AVCodecContext *avctx, AVFrame *frame, AVPacket *pkt, int last) {
    return -1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // register ALL the avcodec bits and pieces
    //avcodec_register_all();
    
    // Do any additional setup after loading the view, typically from a nib.
    UdpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [UdpSocket bindToPort:1338 error:nil];
    
    //if (![UdpSocket bindToAddress:@"127.0.0.1" port:1338 error:nil])
    //NSLog(@"Bind error");
        
    [UdpSocket receiveWithTimeout:-1 tag:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

typedef struct {
    char magic[4];
    int8_t opcode;
    int32_t length;
} SMPacketHeader;

typedef struct {
    int8_t opcode;
    void* data;
    int32_t size;
} SMPacket;


typedef struct {
    char inputFormat[32];
    char outputFormat[32];
    int32_t numFrames;
} SMConfig;


void* SMMakeMeAPacket(int8_t opcode, void* buffer, int32_t size) {
    // create buffer
    void* buff = malloc(size + sizeof(SMPacketHeader));
    memset(buff, 0, size + sizeof(SMPacketHeader));
    
    // header
    SMPacketHeader header;
    header.magic[0] = 'S';
    header.magic[1] = 'U';
    header.magic[2] = 'P';
    header.magic[3] = 'R';
    header.length = size;
    header.opcode = opcode;
    
    // copy header to buffer
    memcpy(buff, (void*)&header, sizeof(SMPacketHeader));
    
    // copy data
    memcpy(&buff[sizeof(SMPacketHeader)], buffer, size);
    
    return buff;
}

SMPacket* SMGiveMeAPacket(const void* buffer, int32_t size) {
    // check for idiots
    if (size < sizeof(SMPacketHeader))
        return NULL;
    
    // header
    SMPacketHeader* header = (SMPacketHeader*)malloc(sizeof(SMPacketHeader));
    memcpy(header, buffer, sizeof(SMPacketHeader));
    
    if (header->magic[0] != 'S' || header->magic[1] != 'U' || header->magic[2] != 'P' || header->magic[3] != 'R') {
        NSLog(@"[supermesh] bad packet, probably not us so...");
        free(header);
        return NULL;
    }
    
    /*printf("%x %x %x %x %x %x %x %x %x %x %x %x %x %x", ((char*)buffer)[0], ((char*)buffer)[1], ((char*)buffer)[2],
           ((char*)buffer)[3], ((char*)buffer)[4], ((char*)buffer)[5], ((char*)buffer)[6], ((char*)buffer)[7], ((char*)buffer)[8],
           ((char*)buffer)[9], ((char*)buffer)[10], ((char*)buffer)[11], ((char*)buffer)[12], ((char*)buffer)[13]);*/
    
    // create packet
    SMPacket* packet = (SMPacket*)malloc(sizeof(SMPacket));
    
    if (packet == NULL) {
        NSLog(@"[supermesh] failed to allocate packet");
        return NULL;
    }
    
    packet->opcode = header->opcode;
    packet->size = header->length;
    
    // check if length
    if (header->length > 10000000) {
        free(header);
        printf("[supermesh] packet too big: %i", header->length);`
        return NULL;
    }
    
    // copy buffer to packet
    void* packetBuff = malloc(header->length);
    
    // check if successful
    if (packetBuff == NULL) {
        NSLog(@"[supermesh] failed to allocate packet data");
        free(packet);
        free(header);
        return NULL;
    }
    
    memcpy(packetBuff, &buffer[sizeof(SMPacketHeader)], header->length);
    packet->data = packetBuff;
    free(header);
    
    return packet;
}

void SMDestroyPacket(SMPacket* packet) {
    // check for idiots
    if (packet == NULL)
        return;
    
    // free
    free(packet->data);
    free(packet);
}

-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data
           withTag:(long)tag
          fromHost:(NSString *)host
              port:(UInt16)port
{
    // create packet
    SMPacket* packet = SMGiveMeAPacket(data.bytes, (int32_t)data.length);
    
    if (packet == NULL) {
        goto error_eww;
    }
    
    if (packet->opcode == 0) {
        SMConfig* config = (SMConfig*)packet->data;
        NSString* str = [NSString stringWithUTF8String:config->inputFormat];
    }
    
    if (packet->opcode == 1) {
        char* blah = malloc(6);
        blah[5] = '\0';
        memcpy(blah, packet->data, 5);
        printf("Hey we got: %s", blah);
    }
    
    // destroy packet
    SMDestroyPacket(packet);
    NSLog(@"Received UDP Packet");
    
    /* deal with the data, put into libav
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
    } */
    
    

    /*NSData *TxData = [NSData dataWithBytes:&header length:TxDataIndex];
				
    [UdpSocket sendData:TxData
                  toHost:host
                    port:1234
             withTimeout:2.0		//Seconds
                     tag:0];
    
    */
error_eww:
    [UdpSocket receiveWithTimeout:-1 tag:1];			//Setup to receive next UDP packet
    return YES;			//Signal that we didn't ignore the packet.
}

@end
