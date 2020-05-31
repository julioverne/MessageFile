#import <dlfcn.h>
#import <objc/runtime.h>
#import <notify.h>
#import <substrate.h>
#import <sys/stat.h>

#define isDeviceIPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define dataFoldeIcon "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x1D\x00\x00\x00\x19\x08\x03\x00\x00\x00\xFA\xDC\xD5\x2B\x00\x00\x00\x72\x50\x4C\x54\x45\x00\x00\x00\x39\x39\x39\xA8\xA8\xA8\xA7\xA7\xA7\xAF\xAF\xAF\x5B\x5B\x5B\x62\x62\x62\xEE\xEE\xEE\xB8\xB8\xB8\xA0\xA0\xA0\x40\x40\x40\x9E\x9E\x9E\x16\x16\x16\x0C\x0C\x0C\x24\x24\x24\x73\x73\x73\xAA\xAA\xAA\xB1\xB1\xB1\xB7\xB7\xB7\xBC\xBC\xBC\xE1\xE1\xE1\xE6\xE6\xE6\x1C\x1C\x1C\x1F\x1F\x1F\x28\x28\x28\x3B\x3B\x3B\x51\x51\x51\x54\x54\x54\x63\x63\x63\x79\x79\x79\x8C\x8C\x8C\x8D\x8D\x8D\x95\x95\x95\xC2\xC2\xC2\xEC\xEC\xEC\xF4\xF4\xF4\xFE\xFE\xFE\x00\x00\x00\x7E\x54\xEF\xD8\x00\x00\x00\x25\x74\x52\x4E\x53\x00\xCA\x58\x5D\x55\xA5\x9E\x14\x4E\x5F\xC4\x66\xEE\xF7\xDF\x93\x5B\x53\x4E\x48\x23\x1E\xE6\xE4\xDB\xC6\xB4\xB1\x9D\x8D\x7A\x77\x6E\x42\x17\x0F\x04\xB3\x2D\x63\x39\x00\x00\x00\x78\x49\x44\x41\x54\x28\xCF\xED\xCE\x37\x12\x84\x30\x10\x44\xD1\xD6\xC2\x3A\x49\x78\x58\xEF\x97\xBE\xFF\x15\x49\x28\x46\x05\x4C\x46\xC8\x8B\xBA\xEA\x27\x8D\xC6\x72\x70\xFF\x63\xC4\x9E\x3E\xC7\xDE\x3B\xC9\x30\x42\x27\x3B\xF3\x93\x9A\xCB\xFE\xF2\x59\x1E\x06\xD5\x0F\x60\x04\xF1\x4A\x18\xF0\x15\x58\x20\xD0\xEE\x45\x73\xF3\xE0\x75\x1B\xD8\x05\x1E\x96\x60\x6A\x34\x17\x82\x31\x34\x25\xE5\xD5\x54\xBC\xD6\x05\x6B\x0E\x4D\x41\xD0\x41\x13\x11\xE6\xEC\x36\xF3\x5C\x6A\x50\x5B\x6A\x4C\xDD\x01\x75\xB9\x11\xDD\x74\x13\xBF\x74\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82"
#define dataLenFoldeIcon 352

@interface CKComposition : NSObject
- (id)compositionByAppendingMediaObjects:(id)arg1;
- (id)compositionByAppendingMediaObject:(id)arg1;
@end

@interface CKIMFileTransfer : NSObject
- (id)initWithFileURL:(NSURL *)arg1 transcoderUserInfo:(NSDictionary *)arg2 attributionInfo:(NSDictionary *)arg3 hideAttachment:(BOOL)arg4;
@end

@interface CKMediaObject : NSObject
- (id)initWithTransfer:(CKIMFileTransfer *)arg1;
- (id)initWithTransfer:(id)arg1 isFromMe:(BOOL)arg2 suppressPreview:(BOOL)arg3 forceInlinePreview:(BOOL)arg4 ; // ios 13
@end

@interface CKMessageEntryView : UIView
@property (nonatomic,retain) UIButton * photoButton; 
- (void)photoButtonTapped:(id)arg1;
@end

@interface CKChatController : UIViewController

@property (nonatomic,retain) UIButton * buttonFileAdd;
@property (nonatomic,retain) NSMutableArray * fileURLAttackArray;

@property (nonatomic,retain) CKComposition * composition;
-(CKMessageEntryView *)entryView;
-(void)showKeyboard;
-(void)showKeyboardForReply;
@end


@interface SBApplication : NSObject
- (id)bundleIdentifier;
- (id)displayName;
@end

@interface UIApplication ()
- (UIDeviceOrientation)_frontMostAppOrientation;
- (SBApplication*)_accessibilityFrontMostApplication;
@end


@interface UIActionSheet ()
- (NSString *) context;
- (void) setContext:(NSString *)context;
@end

@interface UITextField (Apple)
- (UITextField *) textInputTraits;
@end

@interface UIAlertView (Apple)
- (void) addTextFieldWithValue:(NSString *)value label:(NSString *)label;
- (id) buttons;
- (NSString *) context;
- (void) setContext:(NSString *)context;
- (void) setNumberOfRows:(int)rows;
- (void) setRunsModal:(BOOL)modal;
- (UITextField *) textField;
- (UITextField *) textFieldAtIndex:(NSUInteger)index;
- (void) _updateFrameForDisplay;
@end

@interface UIProgressHUD : UIView
- (void) hide;
- (void) setText:(NSString*)text;
- (void) showInView:(UIView *)view;
@end
