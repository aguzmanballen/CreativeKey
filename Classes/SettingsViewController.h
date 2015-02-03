//
//  ListenerViewController.h
//  SafeSound
//
//  Created by Demetri Miller on 10/25/10.
//  Copyright 2010 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RIOInterface;

@interface SettingsViewController : UIViewController {
	IBOutlet UILabel *currentPitchLabel;
    IBOutlet UILabel *currentPitchName;
	IBOutlet UIButton *listenButton;
    IBOutlet UIButton *selectInstrumentButton;
    IBOutlet UIPickerView *instrumentSelectorSlide;
	
	BOOL isListening;
	RIOInterface *rioRef;
	NSMutableArray *instrumentOptions;
	
    NSMutableString *key;
    NSString *pitchName;
    int instrumentChoice;
	float currentFrequency;
	NSString *prevChar;
}

@property(nonatomic, retain) UILabel *currentPitchLabel;
@property(nonatomic, retain) UILabel *currentPitchName;
@property(nonatomic, retain) UIButton *listenButton;
@property(nonatomic, retain) UIButton *selectInstrumentButton;
@property(nonatomic, retain) UIPickerView *instrumentSelectorSlide;
@property(nonatomic, retain) UIImageView *musicalNoteImage;
@property(nonatomic, retain) NSMutableString *key;
@property(nonatomic, retain) NSString *prevChar;
@property(nonatomic, assign) RIOInterface *rioRef;
@property(nonatomic, assign) NSString *pitchName;
@property(nonatomic, assign) int instrumentChoice;
@property(nonatomic, assign) float currentFrequency;
@property(assign) BOOL isListening;


#pragma mark Listener Controls
- (IBAction)toggleListening:(id)sender;
- (IBAction)selectInstrumentAction:(id)sender;
- (void)startListener;
- (void)stopListener;

- (void)frequencyChangedWithValue:(float)newFrequency;
- (void)updateFrequencyLabel;
- (void)displayMusicalNote;

@end
