#import <CommonCrypto/CommonCrypto.h>
#import <GoogleMaps/GoogleMaps.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Contact.h
@interface Contact : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageColor;

//-(BOOL)hasImage;
//-(void)save;

//+(Contact *)contactFromDictionary:(NSDictionary *)dict;
//+(Contact *)queryForName:(NSString *)name;

@end


// Message.h
typedef NS_ENUM(NSInteger, MessageStatus)
{
    MessageStatusSending,
    MessageStatusSent,
    MessageStatusReceived,
    MessageStatusRead,
    MessageStatusFailed
};

typedef NS_ENUM(NSInteger, MessageSender)
{
    MessageSenderMyself,
    MessageSenderSomeone
};

//
// This class is the message object itself
//
@interface Message : NSObject

@property (assign, nonatomic) MessageSender sender;
@property (assign, nonatomic) MessageStatus status;
@property (assign, nonatomic) int identifier;
@property (strong, nonatomic) NSString *chat_id;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) NSInteger time;
@property (assign, nonatomic) CGFloat heigh;

+(Message *)messageFromDictionary:(NSDictionary *)dictionary;

@end

// Chat.h
@interface Chat : NSObject

@property (strong, nonatomic) Message *last_message;
@property (strong, nonatomic) Contact *contact;
@property (assign, nonatomic) NSInteger numberOfUnreadMessages;
@property (strong, nonatomic) NSDate *date;

-(NSString *)identifier;
-(void)save;

@end

// LocalStorage.h
@interface LocalStorage : NSObject

+(id)sharedInstance;
-(void)clear;
+(void)storeChat:(Chat *)chat;
+(void)storeChats:(NSArray *)chats;
+(void)storeContact:(Contact *)contact;
+(void)storeContacts:(NSArray *)contacts;
-(void)storeMessage:(Message *)message;
-(void)storeMessages:(NSArray *)messages;
-(NSArray *)queryMessagesForChatID:(NSString *)chat_id;

@end


// DAKeyboardControl.h
typedef void (^DAKeyboardDidMoveBlock)(CGRect keyboardFrameInView, BOOL opening, BOOL closing);

/** DAKeyboardControl allows you to easily add keyboard awareness and scrolling
 dismissal (a receding keyboard ala iMessages app) to any UIView, UIScrollView
 or UITableView with only 1 line of code. DAKeyboardControl automatically
 extends UIView and provides a block callback with the keyboard's current origin.
 */

@interface UIView (DAKeyboardControl)

/** The keyboardTriggerOffset property allows you to choose at what point the
 user's finger "engages" the keyboard.
 */
@property (nonatomic) CGFloat keyboardTriggerOffset;
@property (nonatomic, readonly) BOOL keyboardWillRecede;

/** Adding pan-to-dismiss (functionality introduced in iMessages)
 @param didMoveBlock called everytime the keyboard is moved so you can update
 the frames of your views
 @see addKeyboardNonpanningWithActionHandler:
 @see removeKeyboardControl
 */
- (void)addKeyboardPanningWithActionHandler:(DAKeyboardDidMoveBlock)didMoveBlock;
- (void)addKeyboardPanningWithFrameBasedActionHandler:(DAKeyboardDidMoveBlock)didMoveFrameBasesBlock
                         constraintBasedActionHandler:(DAKeyboardDidMoveBlock)didMoveConstraintBasesBlock;

/** Adding keyboard awareness (appearance and disappearance only)
 @param didMoveBlock called everytime the keyboard is moved so you can update
 the frames of your views
 @see addKeyboardPanningWithActionHandler:
 @see removeKeyboardControl
 */
- (void)addKeyboardNonpanningWithActionHandler:(DAKeyboardDidMoveBlock)didMoveBlock;
- (void)addKeyboardNonpanningWithFrameBasedActionHandler:(DAKeyboardDidMoveBlock)didMoveFrameBasesBlock
                            constraintBasedActionHandler:(DAKeyboardDidMoveBlock)didMoveConstraintBasesBlock;

/** Remove the keyboard action handler
 @note You MUST call this method to remove the keyboard handler before the view
 goes out of memory.
 */
- (void)removeKeyboardControl;

/** Returns the keyboard frame in the view */
- (CGRect)keyboardFrameInView;
@property (nonatomic, readonly, getter = isKeyboardOpened) BOOL keyboardOpened;

/** Convenience method to dismiss the keyboard */
- (void)hideKeyboard;

@end


// HPGrowingTextView
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
// UITextAlignment is deprecated in iOS 6.0+, use NSTextAlignment instead.
// Reference: https://developer.apple.com/library/ios/documentation/uikit/reference/NSString_UIKit_Additions/Reference/Reference.html
#define NSTextAlignment UITextAlignment
#endif

@class HPGrowingTextView;
@class HPTextViewInternal;

@protocol HPGrowingTextViewDelegate

@optional
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView;

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView;
- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView;

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView;

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height;
- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height;

- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView;
@end

@interface HPGrowingTextView : UIView <UITextViewDelegate> {
    HPTextViewInternal *internalTextView;
    
    int minHeight;
    int maxHeight;
    
    //class properties
    int maxNumberOfLines;
    int minNumberOfLines;
    
    BOOL animateHeightChange;
    NSTimeInterval animationDuration;
    
    //uitextview properties
    NSObject <HPGrowingTextViewDelegate> *__unsafe_unretained delegate;
    NSTextAlignment textAlignment;
    NSRange selectedRange;
    BOOL editable;
    UIDataDetectorTypes dataDetectorTypes;
    UIReturnKeyType returnKeyType;
    UIKeyboardType keyboardType;
    
    UIEdgeInsets contentInset;
}

//real class properties
@property int maxNumberOfLines;
@property int minNumberOfLines;
@property (nonatomic) int maxHeight;
@property (nonatomic) int minHeight;
@property BOOL animateHeightChange;
@property NSTimeInterval animationDuration;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UITextView *internalTextView;


//uitextview properties
@property(unsafe_unretained) NSObject<HPGrowingTextViewDelegate> *delegate;
@property(nonatomic,strong) NSString *text;
@property(nonatomic,strong) UIFont *font;
@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic) NSTextAlignment textAlignment;    // default is NSTextAlignmentLeft
@property(nonatomic) NSRange selectedRange;            // only ranges of length 0 are supported
@property(nonatomic,getter=isEditable) BOOL editable;
@property(nonatomic) UIDataDetectorTypes dataDetectorTypes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_0);
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic) UIKeyboardType keyboardType;
@property (assign) UIEdgeInsets contentInset;
@property (nonatomic) BOOL isScrollable;
@property(nonatomic) BOOL enablesReturnKeyAutomatically;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer;
#endif

//uitextview methods
//need others? use .internalTextView
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (BOOL)isFirstResponder;

- (BOOL)hasText;
- (void)scrollRangeToVisible:(NSRange)range;

// call to force a height change (e.g. after you change max/min lines)
- (void)refreshHeight;

@end


// HPTextViewInternal.h
@interface HPTextViewInternal : UITextView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic) BOOL displayPlaceHolder;

@end


// Inputbar.h
//
// Thanks for HansPinckaers for creating an amazing
// Growing UITextView. This class just add design and
// notifications to uitoobar be similar to whatsapp
// inputbar.
//
// https://github.com/HansPinckaers/GrowingTextView
//

@protocol InputbarDelegate;

@interface Inputbar : UIToolbar

@property (nonatomic, assign) id<InputbarDelegate>Delegate;
@property (nonatomic) NSString *placeholder;
@property (nonatomic) UIImage *leftButtonImage;
@property (nonatomic) NSString *rightButtonText;
@property (nonatomic) UIColor  *rightButtonTextColor;

-(void)resignFirstResponder;
-(NSString *)text;

@end

@protocol InputbarDelegate <NSObject>
-(void)inputbarDidPressRightButton:(Inputbar *)inputbar;
-(void)inputbarDidPressLeftButton:(Inputbar *)inputbar;
@optional
-(void)inputbarDidChangeHeight:(CGFloat)new_height;
-(void)inputbarDidBecomeFirstResponder:(Inputbar *)inputbar;
@end


// TableArray.h
@interface TableArray : NSObject

-(void)addObject:(Message *)message;
-(void)addObjectsFromArray:(NSArray *)messages;
-(void)removeObject:(Message *)message;
-(void)removeObjectsInArray:(NSArray *)messages;
-(void)removeAllObjects;
-(NSInteger)numberOfMessages;
-(NSInteger)numberOfSections;
-(NSInteger)numberOfMessagesInSection:(NSInteger)section;
-(NSString *)titleForSection:(NSInteger)section;
-(Message *)objectAtIndexPath:(NSIndexPath *)indexPath;
-(Message *)lastObject;
-(NSIndexPath *)indexPathForLastMessage;
-(NSIndexPath *)indexPathForMessage:(Message *)message;

@end


// MessageGateway.h
@protocol MessageGatewayDelegate;

//
// this class is responsable to send message
// to server and notify status. It's also responsable
// to get messages in local storage.
//
@interface MessageGateway : NSObject

@property (assign, nonatomic) id<MessageGatewayDelegate> delegate;
@property (strong, nonatomic) Chat *chat;

+(id)sharedInstance;
-(void)loadOldMessages;
-(void)updateStatusForMessage:(Message *)message;
-(void)news;
-(void)dismiss;

@end


@protocol MessageGatewayDelegate <NSObject>

@optional
-(void)gatewayDidUpdateStatusForMessage:(Message *)message;
-(void)gatewayDidReceiveMessages:(NSArray *)array;

@end


// MessageCell.h
@interface MessageCell : UITableViewCell

@property (strong, nonatomic) Message *message;
@property (strong, nonatomic) UIButton *resendButton;

-(void)updateMessageStatus;

//Estimate BubbleCell Height
-(CGFloat)height;

@end
