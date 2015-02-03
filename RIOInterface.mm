//
//  RIOInterface.m
//  SafeSound
//
//  Created by Demetri Miller on 10/22/2010.
//  Copyright 2010 Demetri Miller. All rights reserved.
//

#import "RIOInterface.h"
#import "CAStreamBasicDescription.h"
#import "CAXException.h"
#import "ListenerViewController.h"
#define MEDIAN_MAX 5

@implementation RIOInterface

@synthesize listener;
@synthesize audioPlayerDelegate;
@synthesize audioSessionDelegate;
@synthesize sampleRate;
@synthesize frequency;

float MagnitudeSquared(float x, float y);
void ConvertInt16ToFloat(RIOInterface* THIS, void *buf, float *outputBuf, size_t capacity);
int medianCounter = 0;
float median[MEDIAN_MAX];
float frequencyResult;

#pragma mark -
#pragma mark Lifecycle

- (void)dealloc {
	if (processingGraph) {
		AUGraphStop(processingGraph);
	}
	
	// Clean up the audio session
	AVAudioSession *session = [AVAudioSession sharedInstance];
	[session setActive:NO error:nil];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Playback Controls
- (void)startPlayback {
	[self createAUProcessingGraph];
	[self initializeAndStartProcessingGraph];
	//AudioOutputUnitStart(ioUnit);
}


- (void)startPlaybackFromEncodedArray:(NSArray *)encodedArray {
	// TODO: once we have our generated array, set up the timer to
	// play the encoded array correctly.
}

- (void)stopPlayback {
	AUGraphStop(processingGraph);
	//AudioOutputUnitStop(ioUnit);
}


#pragma mark -
#pragma mark Listener Controls
- (void)startListening:(ListenerViewController*)aListener {
	self.listener = aListener;
	[self createAUProcessingGraph];
	[self initializeAndStartProcessingGraph];	
}


- (void)stopListening {
	[self stopProcessingGraph];
}

#pragma mark - 
#pragma mark Generic Audio Controls
- (void)initializeAndStartProcessingGraph {
    if(processingGraph != nil)
    {
        OSStatus result = AUGraphInitialize(processingGraph);
        if (result >= 0) {
            AUGraphStart(processingGraph);
        } else {
            XThrow(result, "error initializing processing graph");
        }
    }
}

- (void)stopProcessingGraph {
	AUGraphStop(processingGraph);
}

int compare (const void * a, const void * b)
{
    return ( *(int*)a - *(int*)b );
}

#pragma mark -
#pragma mark Audio Rendering
OSStatus RenderFFTCallback (void					*inRefCon, 
					   AudioUnitRenderActionFlags 	*ioActionFlags, 
					   const AudioTimeStamp			*inTimeStamp, 
					   UInt32 						inBusNumber, 
					   UInt32 						inNumberFrames, 
					   AudioBufferList				*ioData)
{
	RIOInterface* THIS = (RIOInterface *)inRefCon;
	COMPLEX_SPLIT A = THIS->A;
    COMPLEX_SPLIT B = THIS->A;
	float *dataBuffer = (float*)THIS->dataBuffer;
	float *outputBuffer = THIS->outputBuffer;
	FFTSetup fftSetup = THIS->fftSetup;
	
	uint32_t log2n = THIS->log2n;
	uint32_t n = THIS->n;
	uint32_t nOver2 = THIS->nOver2;
	uint32_t stride = 1;
	int bufferCapacity = THIS->bufferCapacity;
	SInt16 index = THIS->index;
	
	AudioUnit rioUnit = THIS->ioUnit;
	OSStatus renderErr;
	UInt32 bus1 = 1;
	
	renderErr = AudioUnitRender(rioUnit, ioActionFlags, 
								inTimeStamp, bus1, inNumberFrames, THIS->bufferList);
	if (renderErr < 0) {
		return renderErr;
	}
	
	// Fill the buffer with our sampled data. If we fill our buffer, run the
	// fft.
	int read = bufferCapacity - index;
	if (read > inNumberFrames) {
		memcpy((SInt16 *)dataBuffer + index, THIS->bufferList->mBuffers[0].mData, inNumberFrames*sizeof(SInt16));
		THIS->index += inNumberFrames;
	} else {
		// If we enter this conditional, our buffer will be filled and we should 
		// perform the FFT.
		memcpy((SInt16 *)dataBuffer + index, THIS->bufferList->mBuffers[0].mData, read*sizeof(SInt16));
		
		// Reset the index.
		THIS->index = 0;
        float hammingWindow[bufferCapacity];
        float harrisWindow[bufferCapacity];
        for(int i = 0; i < bufferCapacity; i++){
            hammingWindow[i] = 0.54-0.46*cos(2*3.1415926*i/(bufferCapacity-1));
            harrisWindow[i] = 0.35875-0.48829*cos(2*3.1415926*i/(bufferCapacity-1))+0.14128*cos(4*3.1415926*i/(bufferCapacity-1))-0.01168*cos(6*3.1415926*i/(bufferCapacity-1));
        }
				
        // Window is applied
        /*for(int i=0; i<bufferCapacity; i++){
            outputBuffer[i] = outputBuffer[i]*hammingWindow[i];
        }*/
        
        
        float sum;
        float autoCorrelation1[bufferCapacity];
        for(SInt16 l = 0; l < bufferCapacity; l++){
            sum = 0;
            for(SInt16 k = 0; k < bufferCapacity; k++){
                sum += (*((SInt16*)dataBuffer+k))*(*((SInt16*)dataBuffer+k-l))/bufferCapacity;
            }
            autoCorrelation1[l] = sum;
        }
        
        
        //ConvertInt16ToFloat(THIS, autoCorrelation1, outputBuffer, bufferCapacity);
        SInt16 binB;
        volatile SInt16 maxBin = 0;
        float maxBinValue = 0;
        for(binB = 40; binB<259; binB++){
            if(autoCorrelation1[binB] > maxBinValue){
                maxBinValue = autoCorrelation1[binB];
                maxBin = binB;
            }
        }

        ConvertInt16ToFloat(THIS, dataBuffer, outputBuffer, bufferCapacity);
        
		/** 
		 Look at the real signal as an interleaved complex vector by casting it.
		 Then call the transformation function vDSP_ctoz to get a split complex 
		 vector, which for a real signal, divides into an even-odd configuration.
		 */
		vDSP_ctoz((COMPLEX*)outputBuffer, 2, &A, 1, nOver2);
		
		// Carry out a Forward FFT transform.
		vDSP_fft_zrip(fftSetup, &A, stride, log2n, FFT_FORWARD);
		
		// The output signal is now in a split real form. Use the vDSP_ztoc to get
		// a split real vector.
		vDSP_ztoc(&A, 1, (COMPLEX *)outputBuffer, 2, nOver2);
		
        float sumFFT;
		for (int i=0; i<n; i+=2) {
            sumFFT += MagnitudeSquared(outputBuffer[i], outputBuffer[i+1]);
        }
        
        NSLog(@"FDFD: %f", sumFFT);

        median[medianCounter++] = (sumFFT > 50) ? maxBin : 0;
        sumFFT = 0;
        
        if(medianCounter == MEDIAN_MAX)
            medianCounter = 0;
        qsort(median, MEDIAN_MAX, sizeof(float), compare);
        
        frequencyResult = (median[(MEDIAN_MAX-1)/2] == 0) ? 0 : 44100.0/(2*median[(MEDIAN_MAX-1)/2]);
        
        
        
        memset(outputBuffer, 0, n*sizeof(SInt16));
        
        [THIS->listener frequencyChangedWithValue:frequencyResult];
        printf("You just sang this %f\n", frequencyResult);
	}
	
	
	return noErr;
}



float MagnitudeSquared(float x, float y) {
	return ((x*x) + (y*y));
}

void ConvertInt16ToFloat(RIOInterface* THIS, void *buf, float *outputBuf, size_t capacity) {
	AudioConverterRef converter;
	OSStatus err;
	
	size_t bytesPerSample = sizeof(float);
	AudioStreamBasicDescription outFormat = {0};
	outFormat.mFormatID = kAudioFormatLinearPCM;
	outFormat.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked;
	outFormat.mBitsPerChannel = 8 * bytesPerSample;
	outFormat.mFramesPerPacket = 1;
	outFormat.mChannelsPerFrame = 1;	
	outFormat.mBytesPerPacket = bytesPerSample * outFormat.mFramesPerPacket;
	outFormat.mBytesPerFrame = bytesPerSample * outFormat.mChannelsPerFrame;		
	outFormat.mSampleRate = THIS->sampleRate;
	
	const AudioStreamBasicDescription inFormat = THIS->streamFormat;
	
	UInt32 inSize = capacity*sizeof(SInt16);
	UInt32 outSize = capacity*sizeof(float);
	err = AudioConverterNew(&inFormat, &outFormat, &converter);
	err = AudioConverterConvertBuffer(converter, inSize, buf, &outSize, outputBuf);
}

/* Setup our FFT */
- (void)realFFTSetup {
	UInt32 maxFrames = 2048/4;
	dataBuffer = (void*)malloc(maxFrames * sizeof(SInt16));
	outputBuffer = (float*)malloc(maxFrames *sizeof(float));
	log2n = log2f(maxFrames);
	n = 1 << log2n;
	assert(n == maxFrames);
	nOver2 = maxFrames/2;
	bufferCapacity = maxFrames;
	index = 0;
	A.realp = (float *)malloc(nOver2 * sizeof(float));
	A.imagp = (float *)malloc(nOver2 * sizeof(float));
	fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
}


#pragma mark -
#pragma mark Audio Session/Graph Setup
// Sets up the audio session based on the properties that were set in the init
// method.
- (void)initializeAudioSession {
	NSError	*err = nil;
	AVAudioSession *session = [AVAudioSession sharedInstance];
	
	[session setPreferredHardwareSampleRate:sampleRate error:&err];
	[session setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
	[session setActive:YES error:&err];
	
	// After activation, update our sample rate. We need to update because there
	// is a possibility the system cannot grant our request. 
	sampleRate = [session currentHardwareSampleRate];

	[self realFFTSetup];
}


// This method will create an AUGraph for either input or output.
// Our application will never perform both operations simultaneously.
- (void)createAUProcessingGraph {
	OSStatus err;
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription ioUnitDescription;
	ioUnitDescription.componentType = kAudioUnitType_Output;
	ioUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	ioUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	ioUnitDescription.componentFlags = 0;
	ioUnitDescription.componentFlagsMask = 0;
	
	// Declare and instantiate an audio processing graph
	NewAUGraph(&processingGraph);
	
	// Add an audio unit node to the graph, then instantiate the audio unit.
	/* 
	 An AUNode is an opaque type that represents an audio unit in the context
	 of an audio processing graph. You receive a reference to the new audio unit
	 instance, in the ioUnit parameter, on output of the AUGraphNodeInfo 
	 function call.
	 */
	AUNode ioNode;
	AUGraphAddNode(processingGraph, &ioUnitDescription, &ioNode);
	
	AUGraphOpen(processingGraph); // indirectly performs audio unit instantiation
	
	// Obtain a reference to the newly-instantiated I/O unit. Each Audio Unit
	// requires its own configuration.
	AUGraphNodeInfo(processingGraph, ioNode, NULL, &ioUnit);
	
	// Initialize below.
	AURenderCallbackStruct callbackStruct = {0};
	UInt32 enableInput;
	UInt32 enableOutput;
	
	// Enable input and disable output.
	enableInput = 1; enableOutput = 0;
	callbackStruct.inputProc = RenderFFTCallback;
	callbackStruct.inputProcRefCon = self;
	
	err = AudioUnitSetProperty(ioUnit, kAudioOutputUnitProperty_EnableIO, 
							   kAudioUnitScope_Input, 
							   kInputBus, &enableInput, sizeof(enableInput));
	
	err = AudioUnitSetProperty(ioUnit, kAudioOutputUnitProperty_EnableIO, 
							   kAudioUnitScope_Output, 
							   kOutputBus, &enableOutput, sizeof(enableOutput));
	
	err = AudioUnitSetProperty(ioUnit, kAudioOutputUnitProperty_SetInputCallback, 
							   kAudioUnitScope_Input, 
							   kOutputBus, &callbackStruct, sizeof(callbackStruct));
	

	// Set the stream format.
	size_t bytesPerSample = [self ASBDForSoundMode];
	
	err = AudioUnitSetProperty(ioUnit, kAudioUnitProperty_StreamFormat, 
							   kAudioUnitScope_Output, 
							   kInputBus, &streamFormat, sizeof(streamFormat));
	
	err = AudioUnitSetProperty(ioUnit, kAudioUnitProperty_StreamFormat, 
							   kAudioUnitScope_Input, 
							   kOutputBus, &streamFormat, sizeof(streamFormat));
	
	
	
	
	// Disable system buffer allocation. We'll do it ourselves.
	UInt32 flag = 0;
	err = AudioUnitSetProperty(ioUnit, kAudioUnitProperty_ShouldAllocateBuffer,
								  kAudioUnitScope_Output, 
								  kInputBus, &flag, sizeof(flag));


	// Allocate AudioBuffers for use when listening.
	// TODO: Move into initialization...should only be required once.
	bufferList = (AudioBufferList *)malloc(sizeof(AudioBuffer));
	bufferList->mNumberBuffers = 1;
	bufferList->mBuffers[0].mNumberChannels = 1;
	
	bufferList->mBuffers[0].mDataByteSize = 512*bytesPerSample;
	bufferList->mBuffers[0].mData = calloc(512, bytesPerSample);
}


// Set the AudioStreamBasicDescription for listening to audio data. Set the 
// stream member var here as well.
- (size_t)ASBDForSoundMode {
	AudioStreamBasicDescription asbd = {0};
	size_t bytesPerSample;
	bytesPerSample = sizeof(SInt16);
	asbd.mFormatID = kAudioFormatLinearPCM;
	asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	asbd.mBitsPerChannel = 8 * bytesPerSample;
	asbd.mFramesPerPacket = 1;
	asbd.mChannelsPerFrame = 1;	
	asbd.mBytesPerPacket = bytesPerSample * asbd.mFramesPerPacket;
	asbd.mBytesPerFrame = bytesPerSample * asbd.mChannelsPerFrame;			
	asbd.mSampleRate = sampleRate;		
	
	streamFormat = asbd;
	[self printASBD:streamFormat];
	
	return bytesPerSample;
}

#pragma mark -
#pragma mark Utility
- (void)printASBD:(AudioStreamBasicDescription)asbd {
	
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
	
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    asbd.mBitsPerChannel);
}



// *************** Singleton *********************

static RIOInterface *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (RIOInterface *)sharedInstance
{
	if (sharedInstance == nil) {
		sharedInstance = [[RIOInterface alloc] init];
	}
	
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end