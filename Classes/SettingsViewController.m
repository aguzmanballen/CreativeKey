//
//  ListenerViewController.m
//  SafeSound
//
//  Created by Demetri Miller on 10/25/10.
//  Copyright 2010 Demetri Miller. All rights reserved.
//

#import "SettingsViewController.h"
#import "RIOInterface.h"
#import "KeyHelper.h"

@implementation SettingsViewController

@synthesize currentPitchLabel;
@synthesize currentPitchName;
@synthesize listenButton;
@synthesize selectInstrumentButton;
@synthesize instrumentSelectorSlide;
@synthesize musicalNoteImage;
@synthesize key;
@synthesize prevChar;
@synthesize isListening;
@synthesize	rioRef;
@synthesize pitchName;
@synthesize instrumentChoice;
@synthesize currentFrequency;

#pragma mark -
#pragma mark Listener Controls
- (IBAction)toggleListening:(id)sender {
	if (isListening) {
		[self stopListener];
		[listenButton setTitle:@"Listen" forState:UIControlStateNormal];
	} else {
		[self startListener];
		[listenButton setTitle:@"Stop" forState:UIControlStateNormal];
	}
	
	isListening = !isListening;
}

- (IBAction)selectInstrumentAction:(id)sender {
    instrumentSelectorSlide.hidden = !instrumentSelectorSlide.hidden;
}

- (void)startListener {
	[rioRef startListening:self];
}

- (void)stopListener {
	[rioRef stopListening];
}

- (void)displayMusicalNote {
    
}

#pragma mark -
#pragma mark Lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	rioRef = [RIOInterface sharedInstance];
    instrumentSelectorSlide.hidden = !instrumentSelectorSlide.hidden;
    instrumentOptions = [[NSMutableArray alloc] init];
	[instrumentOptions addObject:@"Human Voice"];
	[instrumentOptions addObject:@"Tenor Saxophone"];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	currentPitchLabel = nil;
    currentPitchName = nil;
    listenButton = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [instrumentOptions dealloc];
	[super dealloc];
}

#pragma mark -
#pragma mark Key Management
// This method gets called by the rendering function. Update the UI with
// the character type and store it in our string.
- (void)frequencyChangedWithValue:(float)newFrequency{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	self.currentFrequency = newFrequency;
    
    // InstrumentChoice == 0 signifies playing a C instrument
    if(instrumentChoice == 0) {
        if(newFrequency == 0)
            self.pitchName = @"";
        else if((newFrequency >= 71) && (newFrequency < 75.5))
            self.pitchName = @"D2";
        else if((newFrequency >= 75.5) && (newFrequency < 80))
            self.pitchName = @"D#2/Eb2";
        else if((newFrequency >= 80) && (newFrequency < 84.5))
            self.pitchName = @"E2";
        else if((newFrequency >= 84.5) && (newFrequency < 90))
            self.pitchName = @"F2";
        else if((newFrequency >= 90) && (newFrequency < 95.5))
            self.pitchName = @"F#2/Gb2";
        else if((newFrequency >= 95.5) && (newFrequency < 101))
            self.pitchName = @"G2";
        else if((newFrequency >= 101) && (newFrequency < 107))
            self.pitchName = @"G#2/Ab2";
        else if((newFrequency >= 107) && (newFrequency < 113.5))
            self.pitchName = @"A2";
        else if((newFrequency >= 113.5) && (newFrequency < 120.5))
            self.pitchName = @"A#2/Bb2";
        else if((newFrequency >= 120.5) && (newFrequency < 127.5))
            self.pitchName = @"B2";
        else if((newFrequency >= 127.5) && (newFrequency < 135))
            self.pitchName = @"C3";
        else if((newFrequency >= 135) && (newFrequency < 143))
            self.pitchName = @"C#3/Db3";
        else if((newFrequency >= 143) && (newFrequency < 151.5))
            self.pitchName = @"D3";
        else if((newFrequency >= 151.5) && (newFrequency < 160.5))
            self.pitchName = @"D#3/Eb3";
        else if((newFrequency >= 160.5) && (newFrequency < 170))
            self.pitchName = @"E3";
        else if((newFrequency >= 170) && (newFrequency < 180))
            self.pitchName = @"F3";
        else if((newFrequency >= 180) && (newFrequency < 190.5))
            self.pitchName = @"F#3/Gb3";
        else if((newFrequency >= 190.5) && (newFrequency < 202))
            self.pitchName = @"G3";
        else if((newFrequency >= 202) && (newFrequency < 214))
            self.pitchName = @"G#3/Ab3";
        else if((newFrequency >= 214) && (newFrequency < 226.5))
            self.pitchName = @"A3";
        else if((newFrequency >= 226.5) && (newFrequency < 240))
            self.pitchName = @"A#3/Bb3";
        else if((newFrequency >= 240) && (newFrequency < 254.5))
            self.pitchName = @"B3";
        else if((newFrequency >= 254.5) && (newFrequency < 270))
            self.pitchName = @"C4";
        else if((newFrequency >= 270) && (newFrequency < 286))
            self.pitchName = @"C#4/Db4";
        else if((newFrequency >= 286) && (newFrequency < 302.5))
            self.pitchName = @"D4";
        else if((newFrequency >= 302.5) && (newFrequency < 320.5))
            self.pitchName = @"D#4/Eb4";
        else if((newFrequency >= 320.5) && (newFrequency < 339.5))
            self.pitchName = @"E4";
        else if((newFrequency >= 339.5) && (newFrequency < 359.5))
            self.pitchName = @"F4";
        else if((newFrequency >= 359.5) && (newFrequency < 381))
            self.pitchName = @"F#4/Gb4";
        else if((newFrequency >= 381) && (newFrequency < 403.5))
            self.pitchName = @"G4";
        else if((newFrequency >= 403.5) && (newFrequency < 427.5))
            self.pitchName = @"G#4/Ab4";
        else if((newFrequency >= 427.5) && (newFrequency < 453))
            self.pitchName = @"A4";
        else if((newFrequency >= 453) && (newFrequency < 480))
            self.pitchName = @"A#4/Bb4";
        else if((newFrequency >= 480) && (newFrequency < 508.5))
            self.pitchName = @"B4";
        else if((newFrequency >= 508.5) && (newFrequency < 538.5))
            self.pitchName = @"C5";
        else if((newFrequency >= 538.5) && (newFrequency < 570.5))
            self.pitchName = @"C#5/Db5";
        else if((newFrequency >= 570.5) && (newFrequency < 604.5))
            self.pitchName = @"D5";
        else if((newFrequency >= 604.5) && (newFrequency < 640.5))
            self.pitchName = @"D#5/Eb5";
        else if((newFrequency >= 640.5) && (newFrequency < 679))
            self.pitchName = @"E5";
        else if((newFrequency >= 679) && (newFrequency < 719.5))
            self.pitchName = @"F5";
        else if((newFrequency >= 719.5) && (newFrequency < 762))
            self.pitchName = @"F#5/Gb5";
        else if((newFrequency >= 762) && (newFrequency < 807.5))
            self.pitchName = @"G5";
        else if((newFrequency >= 807.5) && (newFrequency < 855.5))
            self.pitchName = @"G#5/Ab5";
        else if((newFrequency >= 855.5) && (newFrequency < 906))
            self.pitchName = @"A5";
        else if((newFrequency >= 906) && (newFrequency < 960))
            self.pitchName = @"A#5/Bb5";
        else if((newFrequency >= 960) && (newFrequency < 1017.5))
            self.pitchName = @"B5";
        else if((newFrequency >= 1017.5) && (newFrequency < 1078))
            self.pitchName = @"C6";
    }

    // InstrumentChoice == 1 signifies playing a Bb instrument
    else if(instrumentChoice == 1) {
        if(newFrequency == 0)
            self.pitchName = @"";
        else if((newFrequency >= 71) && (newFrequency < 75.5))
            self.pitchName = @"C2";
        else if((newFrequency >= 75.5) && (newFrequency < 80))
            self.pitchName = @"C#2/Db2";
        else if((newFrequency >= 80) && (newFrequency < 84.5))
            self.pitchName = @"D2";
        else if((newFrequency >= 84.5) && (newFrequency < 90))
            self.pitchName = @"D#2/Eb2";
        else if((newFrequency >= 90) && (newFrequency < 95.5))
            self.pitchName = @"E2";
        else if((newFrequency >= 95.5) && (newFrequency < 101))
            self.pitchName = @"F2";
        else if((newFrequency >= 101) && (newFrequency < 107))
            self.pitchName = @"F#2/Gb2";
        else if((newFrequency >= 107) && (newFrequency < 113.5))
            self.pitchName = @"G2";
        else if((newFrequency >= 113.5) && (newFrequency < 120.5))
            self.pitchName = @"G#2/Ab2";
        else if((newFrequency >= 120.5) && (newFrequency < 127.5))
            self.pitchName = @"A2";
        else if((newFrequency >= 127.5) && (newFrequency < 135))
            self.pitchName = @"A#2/Bb2";
        else if((newFrequency >= 135) && (newFrequency < 143))
            self.pitchName = @"B2";
        else if((newFrequency >= 143) && (newFrequency < 151.5))
            self.pitchName = @"C3";
        else if((newFrequency >= 151.5) && (newFrequency < 160.5))
            self.pitchName = @"C#3/Db3";
        else if((newFrequency >= 160.5) && (newFrequency < 170))
            self.pitchName = @"D3";
        else if((newFrequency >= 170) && (newFrequency < 180))
            self.pitchName = @"D#3/Eb3";
        else if((newFrequency >= 180) && (newFrequency < 190.5))
            self.pitchName = @"E3";
        else if((newFrequency >= 190.5) && (newFrequency < 202))
            self.pitchName = @"F3";
        else if((newFrequency >= 202) && (newFrequency < 214))
            self.pitchName = @"F#3/Gb3";
        else if((newFrequency >= 214) && (newFrequency < 226.5))
            self.pitchName = @"G3";
        else if((newFrequency >= 226.5) && (newFrequency < 240))
            self.pitchName = @"G#3/Ab3";
        else if((newFrequency >= 240) && (newFrequency < 254.5))
            self.pitchName = @"A3";
        else if((newFrequency >= 254.5) && (newFrequency < 270))
            self.pitchName = @"A#3/Bb3";
        else if((newFrequency >= 270) && (newFrequency < 286))
            self.pitchName = @"B3";
        else if((newFrequency >= 286) && (newFrequency < 302.5))
            self.pitchName = @"C4";
        else if((newFrequency >= 302.5) && (newFrequency < 320.5))
            self.pitchName = @"C#4/Db4";
        else if((newFrequency >= 320.5) && (newFrequency < 339.5))
            self.pitchName = @"D4";
        else if((newFrequency >= 339.5) && (newFrequency < 359.5))
            self.pitchName = @"D#4/Eb4";
        else if((newFrequency >= 359.5) && (newFrequency < 381))
            self.pitchName = @"E4";
        else if((newFrequency >= 381) && (newFrequency < 403.5))
            self.pitchName = @"F4";
        else if((newFrequency >= 403.5) && (newFrequency < 427.5))
            self.pitchName = @"F#4/Gb4";
        else if((newFrequency >= 427.5) && (newFrequency < 453))
            self.pitchName = @"G4";
        else if((newFrequency >= 453) && (newFrequency < 480))
            self.pitchName = @"G#4/Ab4";
        else if((newFrequency >= 480) && (newFrequency < 508.5))
            self.pitchName = @"A4";
        else if((newFrequency >= 508.5) && (newFrequency < 538.5))
            self.pitchName = @"A#4/Bb4";
        else if((newFrequency >= 538.5) && (newFrequency < 570.5))
            self.pitchName = @"B4";
        else if((newFrequency >= 570.5) && (newFrequency < 604.5))
            self.pitchName = @"C5";
        else if((newFrequency >= 604.5) && (newFrequency < 640.5))
            self.pitchName = @"C#5/Db5";
        else if((newFrequency >= 640.5) && (newFrequency < 679))
            self.pitchName = @"D5";
        else if((newFrequency >= 679) && (newFrequency < 719.5))
            self.pitchName = @"D#5/Eb5";
        else if((newFrequency >= 719.5) && (newFrequency < 762))
            self.pitchName = @"E5";
        else if((newFrequency >= 762) && (newFrequency < 807.5))
            self.pitchName = @"F5";
        else if((newFrequency >= 807.5) && (newFrequency < 855.5))
            self.pitchName = @"F#5/Gb5";
        else if((newFrequency >= 855.5) && (newFrequency < 906))
            self.pitchName = @"G5";
        else if((newFrequency >= 906) && (newFrequency < 960))
            self.pitchName = @"G#5/Ab5";
        else if((newFrequency >= 960) && (newFrequency < 1017.5))
            self.pitchName = @"A5";
        else if((newFrequency >= 1017.5) && (newFrequency < 1078))
            self.pitchName = @"A#5/Bb5";
    }
    
	[self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
    //[self performSelectorOnMainThread:@selector(updateFrequencyLabel) withObject:nil waitUntilDone:NO];
	/*
	 * If you want to display letter values for pitches, uncomment this code and
	 * add your frequency to pitch mappings in KeyHelper.m
	 */
	
	/*
	KeyHelper *helper = [KeyHelper sharedInstance];
	NSString *closestChar = [helper closestCharForFrequency:newFrequency];
	
	// If the new sample has the same frequency as the last one, we should ignore
	// it. This is a pretty inefficient way of doing comparisons, but it works.
	if (![prevChar isEqualToString:closestChar]) {
		self.prevChar = closestChar;
		if ([closestChar isEqualToString:@"0"]) {
		//	[self toggleListening:nil];
		}
		[self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
		NSString *appendedString = [key stringByAppendingString:closestChar];
		self.key = [NSMutableString stringWithString:appendedString];
	}
	*/
	[pool drain];
	pool = nil;
	
}


		 
- (void)updateFrequencyLabel {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	if(self.currentFrequency == 0){
        self.currentPitchLabel.text = [NSString stringWithFormat:@""];
        [self.currentPitchLabel setNeedsDisplay];
    }
    else {
        self.currentPitchLabel.text = [NSString stringWithFormat:@"%f", self.currentFrequency];
        [self.currentPitchLabel setNeedsDisplay];
    }
    
    self.currentPitchName.text = [NSString stringWithFormat:@"%@", self.pitchName];
    [self.currentPitchName setNeedsDisplay];
    
    [self displayMusicalNote];
    
	[pool drain];
	pool = nil;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	
	return [instrumentOptions count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	return [instrumentOptions objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	NSLog(@"Selected Color: %@. Index of selected color: %i", [instrumentOptions objectAtIndex:row], row);
    instrumentChoice = row;
}
@end
