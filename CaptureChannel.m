/*

File: CaptureChannel.m

Abstract:   The CaptureChannel handles the rendering of frames from the video input through QTCapture.

Version: 1.0

© Copyright 2006 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to 
you by Apple Computer, Inc. ("Apple") in 
consideration of your agreement to the following 
terms, and your use, installation, modification 
or redistribution of this Apple software 
constitutes acceptance of these terms.  If you do 
not agree with these terms, please do not use, 
install, modify or redistribute this Apple 
software.

In consideration of your agreement to abide by 
the following terms, and subject to these terms, 
Apple grants you a personal, non-exclusive 
license, under Apple's copyrights in this 
original Apple software (the "Apple Software"), 
to use, reproduce, modify and redistribute the 
Apple Software, with or without modifications, in 
source and/or binary forms; provided that if you 
redistribute the Apple Software in its entirety 
and without modifications, you must retain this 
notice and the following text and disclaimers in 
all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or 
logos of Apple Computer, Inc. may be used to 
endorse or promote products derived from the 
Apple Software without specific prior written 
permission from Apple.  Except as expressly 
stated in this notice, no other rights or 
licenses, express or implied, are granted by 
Apple herein, including but not limited to any 
patent rights that may be infringed by your 
derivative works or by other works in which the 
Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS 
IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR 
IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED 
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY 
AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING 
THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE 
OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY 
SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL 
DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, 
REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF 
THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER 
UNDER THEORY OF CONTRACT, TORT (INCLUDING 
NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN 
IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF 
SUCH DAMAGE.

*/ 

#import "CaptureChannel.h"
#import "LiveVideoMixerController.h"


@implementation CaptureChannel

+ (id)createWithQTCaptureDevice:(QTRDeviceSet*)theDevice forView:(VideoMixView*)inView
{
	return [[[CaptureChannel alloc] initWithQTCaptureDevice:theDevice forView:inView] autorelease];
}

//--------------------------------------------------------------------------------------------------

- (id)initWithQTCaptureDevice:(QTRDeviceSet*)theDevice forView:(VideoMixView*)inView
{
    OSStatus		theError = noErr;

	self = [super init];
	
    targetRect = NSMakeRect(0.0, 0.0, kVideoWidth, kVideoHeight);	// hard coded video size

	// Create the visual context
	theError = QTOpenGLTextureContextCreate(nil, [[inView sharedContext] CGLContextObj],
						[[NSOpenGLView defaultPixelFormat] CGLPixelFormatObj],
						nil,
						&visualContext);
    if(visualContext == NULL) 
    {
		NSLog(@"QTVisualContext creation failed with error:%d", theError);
		[self dealloc];
		return nil;
    }

	// Create a capture session
	captureSession = [[QTCaptureSession alloc] init];
	[captureSession setDelegate:self];

	[captureSession setEnabled:NO];

	// Add the newly selected input device(s) to the capture session
	switch ([theDevice deviceSetType])
	{
		case 0: // Muxed
			[captureSession addInput:[QTCaptureDeviceInput deviceInputWithDevice:[theDevice muxedCaptureDevice]] error:nil];
			break;
			
		case 1: // Video-only
			[captureSession addInput:[QTCaptureDeviceInput deviceInputWithDevice:[theDevice videoCaptureDevice]] error:nil];
			break;
			
		case 2: // Audio-only
			[captureSession addInput:[QTCaptureDeviceInput deviceInputWithDevice:[theDevice audioCaptureDevice]] error:nil];
			break;
			
		case 3: // Audio-video
			[captureSession addInput:[QTCaptureDeviceInput deviceInputWithDevice:[theDevice audioCaptureDevice]] error:nil];
			[captureSession addInput:[QTCaptureDeviceInput deviceInputWithDevice:[theDevice videoCaptureDevice]] error:nil];
			break;
			
		default:
			break;
	}
	
	// Attach output based on our visual context to session
	captureOutput = [[QTCaptureVideoPreviewOutput alloc] init];
	[captureSession addOutput:captureOutput error:nil];
	[captureOutput setVisualContext:visualContext forChannel:[[captureOutput connectedChannels] objectAtIndex:0]];
		
	[captureSession setEnabled:YES];

	return self;
}

//--------------------------------------------------------------------------------------------------

- (void)dealloc
{
	[captureSession release];
	[captureOutput release];
	[super dealloc];
}	

//--------------------------------------------------------------------------------------------------

- (void)prerollMovie:(Fixed)rate
{
	// do nothing here
}

//--------------------------------------------------------------------------------------------------

- (void)startMovie:(Fixed)rate usingMasterTimeBase:(TimeBase)masterTimeBase
{
	// do nothing here
}

//--------------------------------------------------------------------------------------------------

- (void)stopMovie
{
	// do nothing here
}

//--------------------------------------------------------------------------------------------------

- (TimeBase)timeBase
{
	return 0;	// no timebase available
}

//--------------------------------------------------------------------------------------------------

@end
