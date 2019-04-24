
#define NSLog(...)

#import "Tweak.h"



static void appendMediaObjectsForFilesURL(CKChatController* chatCon, NSArray* filesURL)
{
	NSLog(@"filesURL: %@", filesURL);
	if(chatCon.composition) {
		NSMutableArray* retMut = [NSMutableArray array];
		for(NSURL* fileNow in filesURL) {
			CKIMFileTransfer* Trans = [[CKIMFileTransfer alloc] initWithFileURL:fileNow transcoderUserInfo:@{} attributionInfo:@{} hideAttachment:NO];
			CKMediaObject* mediaOb = [[CKMediaObject alloc] initWithTransfer:Trans];
			[retMut addObject:mediaOb];
		}
		chatCon.composition = [chatCon.composition compositionByAppendingMediaObjects:retMut];	
	}
}

@interface MImportDirBrowserController : UITableViewController <UITableViewDelegate, UIActionSheetDelegate, UITabBarDelegate, UITabBarControllerDelegate>
@property (strong) NSString *path;
@property (strong) NSArray *files;
@property (strong) NSMutableArray *selectedRows;
@property (assign) BOOL editRow;
@property (strong) NSDictionary *contentDir;
@property (strong) UIImage *kImageAudio;
@property (strong) CKChatController* chatCon;
@end

@implementation MImportDirBrowserController
@synthesize path, files, selectedRows, editRow, contentDir, kImageAudio, chatCon;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
	
    if (self) {
		self.selectedRows = [NSMutableArray array];
    }
    return self;
}
- (NSString*)pathForFile:(NSString*)file
{
	return [self.path stringByAppendingPathComponent:file];
}
- (BOOL)fileIsDirectory:(NSString*)file
{
	BOOL isDir = NO;
	if(id isDirValue = [[[self.contentDir objectForKey:@"content"] objectForKey:file] objectForKey:@"isDir"]) {
		isDir = [isDirValue boolValue];
	}	
	return isDir;
}
- (BOOL)extensionIsSupported:(NSString*)ext
{
	return YES;
}
- (void)Refresh
{
	dispatch_async(dispatch_get_main_queue(), ^(void){
	if (!self.path) {
		self.path = @"/var/mobile";
	}
	NSMutableArray* tempFiles = [NSMutableArray array];
	
	//[[UIPasteboard generalPasteboard] setData:[NSData data] forPasteboardType:@"messageFile-path"];
	//[[UIPasteboard generalPasteboard] setData:[NSData data] forPasteboardType:@"messageFile-path-content"];
	
	[[UIPasteboard generalPasteboard] setData:[self.path dataUsingEncoding:NSUTF8StringEncoding] forPasteboardType:@"messageFile-path"];
	
	
	while([[UIPasteboard generalPasteboard] dataForPasteboardType:@"messageFile-path"].length > 0) {
		sleep(1/2);
	}
	
	
	
	NSData* data = [NSData dataWithContentsOfFile:@"/tmp/messageFileDir"];
	
	NSLog(@"data: %@", data);
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	//NSLog(@"response == %@", [unarchiver decodeObjectForKey:@"response"]);
	self.contentDir = [unarchiver?[unarchiver decodeObjectForKey:@"response"]?:@{}:@{} copy];
	self.files = [[self.contentDir objectForKey:@"content"]?:@{} allKeys];
	self.files = [self.files sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	
	for(NSString*file in self.files) {
		BOOL isdir = [self fileIsDirectory:file];
		if(isdir) {
			[tempFiles addObject:file];
		} else {
			NSString *ext = [[file pathExtension]?:@"" lowercaseString];
			if ([self extensionIsSupported:ext]) {
				[tempFiles addObject:file];
			}
		}
	}
	self.files = [tempFiles copy];
	self.title = [self.path lastPathComponent];
	self.navigationItem.backBarButtonItem.title = [[self.path lastPathComponent] lastPathComponent];
	[self.tableView reloadData];
	
	});
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self Refresh];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	__strong UIBarButtonItem* kBTClose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeMImport)];
	kBTClose.tag = 4;	
	if (self.navigationController.navigationBar.backItem == NULL) {
		self.navigationItem.leftBarButtonItem = kBTClose;
	}
}
- (void)setRightButton
{
	__strong UIBarButtonItem * kBTRight;
	__strong UIBarButtonItem* kBTClose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeMImport)];
	__strong UIBarButtonItem *noButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"•••" style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
	noButtonItem.tag = 4;
	self.navigationItem.rightBarButtonItems = @[kBTClose, noButtonItem];
	
	if(self.editRow) {
		kBTRight = [[UIBarButtonItem alloc] initWithTitle:[[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/PhotoLibrary.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"IMPORT_SELECTED" value:@"Import Selected" table:@"PhotoLibrary"] style:UIBarButtonItemStylePlain target:self action:@selector(selectRow)];
		__strong UIBarButtonItem *kCancel = [[UIBarButtonItem alloc] initWithTitle:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/UIKit.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil] style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelectRow)];
		__strong UIBarButtonItem *kSelectAll = [[UIBarButtonItem alloc] initWithTitle:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/UIKit.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"Select All" value:@"Select All" table:nil] style:UIBarButtonItemStylePlain target:self action:@selector(selectAllRow)];
		kBTRight.tag = 4;
		kCancel.tag = 4;
		if([self.selectedRows count] > 0) {
			self.navigationItem.rightBarButtonItems = @[kBTClose, kCancel, kBTRight, ];
		} else {
			self.navigationItem.rightBarButtonItems = @[kBTClose, kCancel, kSelectAll, ];
		}		
	} else {
		self.navigationItem.rightBarButtonItems = @[kBTClose, noButtonItem];
	}
	
}
- (void)showOptions
{
	UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	[popup setContext:@"more"];
	
	if(!self.editRow && ([self.files count]>0)) {
		[popup addButtonWithTitle:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/UIKit.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"Select" value:@"Select" table:nil]];
	}
	
	if(self.path && [self.path lastPathComponent]!=nil && [self.path lastPathComponent].length > 0) {
		[popup addButtonWithTitle:@"Open subfolder"];
	}
	
	[popup addButtonWithTitle:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/UIKit.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil]];
	[popup setCancelButtonIndex:[popup numberOfButtons] - 1];
	if (isDeviceIPad) {
		[popup showFromBarButtonItem:[[self navigationItem] rightBarButtonItem] animated:YES];
	} else {
		[popup showInView:self.view];
	}
}
- (void)selectAllRow
{
	self.selectedRows = [NSMutableArray array];
	for(int i = 0; i <= [self tableView:(UITableView*)self numberOfRowsInSection:0]; i++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		if(cell) {
			if(cell.accessoryType != UITableViewCellAccessoryDisclosureIndicator) {
				[self.selectedRows addObject:@(indexPath.row)];
			}
		}
	}
	[self Refresh];
	[self setRightButton];
}
- (void)viewDidLoad
{
	[super viewDidLoad];
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:refreshControl];
	
	self.tableView.allowsMultipleSelection = YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];	
	if(cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {		
		return;
	}	
    
	if ([self.selectedRows containsObject:@(indexPath.row)]) {
		[self.selectedRows removeObject:@(indexPath.row)];
	}
	
	if(cell.accessoryType == UITableViewCellAccessoryNone) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		[self.selectedRows addObject:@(indexPath.row)];
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	[self setRightButton];
}

- (void)cancelSelectRow
{
	self.editRow = NO;
	self.selectedRows = [NSMutableArray array];
	[self Refresh];
	[self setRightButton];
}
- (void)loadView
{
	[super loadView];	
	[self setRightButton];
}

- (void)selectRow
{
	self.editRow = !self.editRow;
	[self setRightButton];
	int total = [self.selectedRows count];
	if(!self.editRow && (total > 0)) {
		__block UIProgressHUD* hud = [[UIProgressHUD alloc] init];
		[hud setText:@"Loading..."];
		[hud showInView:self.view];
		[self.view setUserInteractionEnabled:NO];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSMutableArray* filesURLToImport = [[NSMutableArray alloc] init];
			int index = 0;
			for(id indexNowValue in self.selectedRows) {
				index++;
				int indexNow = [indexNowValue intValue];
				NSString *file = [self.files objectAtIndex:indexNow];
				NSString *pathS = [self pathForFile:file];
				
				[[UIPasteboard generalPasteboard] setData:[pathS dataUsingEncoding:NSUTF8StringEncoding] forPasteboardType:@"messageFile-file"];
				while([[UIPasteboard generalPasteboard] dataForPasteboardType:@"messageFile-file"].length > 0) {
					sleep(1/2);
				}
				[filesURLToImport addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"/tmp/%@", [pathS lastPathComponent]]]];
				
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					[hud setText:[NSString stringWithFormat:@"Adding %d of %d ...", index, total]];
				});
			}
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				
				appendMediaObjectsForFilesURL(chatCon, [filesURLToImport copy]);
				
				[self.view setUserInteractionEnabled:YES];
				[hud hide];
				[self cancelSelectRow];
				[self closeMImport];
			});
		});
	}
}
- (void)closeMImport
{
	[self dismissViewControllerAnimated:YES completion:nil];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.8f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[chatCon showKeyboardForReply];
	});
}
- (void)refreshView:(UIRefreshControl *)refresh
{
	[self Refresh];
	[refresh endRefreshing];
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return self.path;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.text = self.path;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.files count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static __strong NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		//cell.textLabel.font = [UIFont fontWithName: @"Arial" size:14.0];
		//cell.detailTextLabel.font = [UIFont fontWithName: @"Arial" size:11.0];
    }
	NSString *file = [self.files objectAtIndex:indexPath.row];
	//NSString *path = [self pathForFile:file];
	static __strong UIImage* kIconFolder = nil;//[[UIImage imageWithImage:[UIImage imageNamed:@"folder.png"]] copy];
	if(!kIconFolder) {
		NSData* dataImage = [[NSData alloc] initWithBytes:dataFoldeIcon length:dataLenFoldeIcon];
		kIconFolder = [[[UIImage alloc] initWithData:dataImage] copy];
	}
	BOOL isdir = [self fileIsDirectory:file];
	//[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isdir];
	//NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	//int size = [attributes[NSFileSize] intValue];
	int size = 0;
	if(id sizeValue = [[[self.contentDir objectForKey:@"content"] objectForKey:file] objectForKey:@"size"]) {
		size = [sizeValue intValue];
	}
	BOOL isLink = NO;
	if(id isLinkValue = [[[self.contentDir objectForKey:@"content"] objectForKey:file] objectForKey:@"isLink"]) {
		isLink = [isLinkValue boolValue];
	}
	//cell.textLabel.text = file;
	cell.textLabel.text =  file;
	cell.textLabel.textColor = isLink&&isdir ? [UIColor blueColor] : [UIColor darkTextColor];
	cell.accessoryType = isdir ? UITableViewCellAccessoryDisclosureIndicator : [self.selectedRows containsObject:@(indexPath.row)]?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
	cell.imageView.image = isdir ? kIconFolder : nil;
	static __strong NSString* kKB = @"%.f KB";
	static __strong NSString* kMB = @"%.1f MB";
	cell.detailTextLabel.text = isdir ? nil : [NSString stringWithFormat:size>=1048576?kMB:kKB, size>=1048576?(float)size/1048576:(float)size/1024];
	if (!isdir) {
		NSString *ext = [[file pathExtension]?:@"" lowercaseString];
		if ([self extensionIsSupported:ext]) {
			
			//cell.imageView.image = kIconMimportGet();
	    } else {
			//static __strong UIImage* kImageInstall = [[UIImage imageWithImage:[UIImage imageNamed:@"install.png"]] copy];
			cell.imageView.image = nil;
		}
	} else {
		
		//cell.imageView.image = kImageDirGet();
	}
	
    return cell;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(self.editRow) {
		return indexPath;
	}
	NSString *file = [self.files objectAtIndex:indexPath.row];
	NSString *pathS = [self pathForFile:file];
	if ([self fileIsDirectory:file]) {
		if([self.path isEqualToString:pathS]) {
			return nil;
		}
		MImportDirBrowserController *dbtvc = [[[MImportDirBrowserController alloc] init] initWithStyle:self.tableView.style];
		dbtvc.path = pathS;
		dbtvc.chatCon = chatCon;
		@try {
			[self.navigationController pushViewController:dbtvc animated:YES];
		} @catch (NSException * e) {
		}
    } else {
		UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:file delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
		[popup addButtonWithTitle:[[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/PhotoLibrary.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"IMPORT" value:@"Import" table:@"PhotoLibrary"]];
		[popup addButtonWithTitle:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/UIKit.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil]];
		[popup setCancelButtonIndex:[popup numberOfButtons] - 1];
		popup.tag = indexPath.row;
		if (isDeviceIPad) {
			[popup showFromBarButtonItem:[[self navigationItem] rightBarButtonItem] animated:YES];
		} else {
			[popup showInView:self.view];
		}
	}
	return nil;
}
- (void)actionSheet:(UIActionSheet *)alert clickedButtonAtIndex:(NSInteger)button 
{
	if (button == [alert cancelButtonIndex]) {
		return;
	}
	
	NSString* contextAlert = [alert context];
	NSString* buttonTitle = [[alert buttonTitleAtIndex:button] copy];
	
	if(contextAlert&&[contextAlert isEqualToString:@"more"]) {
		
		if ([buttonTitle isEqualToString:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/UIKit.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"Select" value:@"Select" table:nil]]) {
			[self performSelector:@selector(selectRow) withObject:nil afterDelay:0];
		} else if ([buttonTitle isEqualToString:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/UIKit.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil]]) {
			[self performSelector:@selector(cancelSelectRow) withObject:nil afterDelay:0];
		} else if ([buttonTitle isEqualToString:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/UIKit.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"Select All" value:@"Select All" table:nil]]) {
			[self performSelector:@selector(selectAllRow) withObject:nil afterDelay:0];
		} else if ([buttonTitle isEqualToString:@"Open subfolder"]) {
			@try {
				MImportDirBrowserController *dbtvc = [[[MImportDirBrowserController alloc] init] initWithStyle:self.tableView.style];
				dbtvc.path = [self.path stringByDeletingLastPathComponent];
				[self.navigationController pushViewController:dbtvc animated:YES];
			} @catch (NSException * e) {
			}
		}
		return;
	}
	
	NSString *file = [[self.files objectAtIndex:[alert tag]] copy];
	NSString *pathS = [[self pathForFile:file] copy];
	if([buttonTitle isEqualToString:[[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/PhotoLibrary.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"IMPORT" value:@"Import" table:@"PhotoLibrary"]]) {
		
		[[UIPasteboard generalPasteboard] setData:[pathS dataUsingEncoding:NSUTF8StringEncoding] forPasteboardType:@"messageFile-file"];
		
		while([[UIPasteboard generalPasteboard] dataForPasteboardType:@"messageFile-file"].length > 0) {
			sleep(1/2);
		}
		
		appendMediaObjectsForFilesURL(chatCon, [@[[NSURL fileURLWithPath:[NSString stringWithFormat:@"/tmp/%@", [pathS lastPathComponent]]]] copy]);
		[self closeMImport];
		
		return;
	}
	return;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if(section == [self numberOfSectionsInTableView:tableView]-1) {
		return @"MessageFile © 2018";
	}
	return [super tableView:tableView titleForFooterInSection:section];
}
@end

static CKChatController* currCKChatController;

%hook CKMessageEntryView
- (void)photoButtonTapped:(id)arg1
{
	if(arg1) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/UIKit.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"Action" value:@"Action" table:nil] message:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/MessageUI.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"IMPORT_DOCUMENT" value:@"Add Media" table:@"Main"] delegate:self cancelButtonTitle:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/UIKit.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil] otherButtonTitles:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/MessageUI.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"INSERT_PHOTO_OR_VIDEO" value:@"Add Photo or Video" table:@"Main"], @"Root Filesystem", nil];
		[alert show];
		return;
	}
	%orig;
}
%new
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
	NSString* buttonTitle = [[alertView buttonTitleAtIndex:buttonIndex]?:@"" copy];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
	if([buttonTitle isEqualToString:[[NSBundle bundleWithPath:@"/System/Library/Frameworks/MessageUI.framework"]?:[NSBundle mainBundle] localizedStringForKey:@"INSERT_PHOTO_OR_VIDEO" value:@"Add Photo or Video" table:@"Main"]]) {
		[self photoButtonTapped:nil];
	} else if([buttonTitle isEqualToString:@"Root Filesystem"]) {
		MImportDirBrowserController *dbtvc = [[[MImportDirBrowserController alloc] init] initWithStyle:UITableViewCellStyleSubtitle];
		dbtvc.path = @"/";
		dbtvc.chatCon = currCKChatController;
		@try {
			UINavigationController* nacV = [[UINavigationController alloc] initWithRootViewController:dbtvc];
			[currCKChatController presentViewController:nacV animated:YES completion:nil];
		} @catch (NSException * e) {
		}
	}
	});
}
%end

%hook CKChatController
%property(assign) id buttonFileAdd;
- (void)viewDidAppear:(BOOL)arg1
{
	currCKChatController = self;
	%orig;
}
- (void)viewDidLayoutSubviews
{
	currCKChatController = self;
	%orig;
}
%new
- (void)buttonFileAddPressed
{
	MImportDirBrowserController *dbtvc = [[[MImportDirBrowserController alloc] init] initWithStyle:UITableViewCellStyleSubtitle];
	dbtvc.path = @"/";
	dbtvc.chatCon = self;
	@try {
		UINavigationController* nacV = [[UINavigationController alloc] initWithRootViewController:dbtvc];
		[self presentViewController:nacV animated:YES completion:nil];
	} @catch (NSException * e) {
	}
}
%end



%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
	%orig;
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkHandleMessageFile) userInfo:nil repeats:YES];
}
%new
- (void)checkHandleMessageFile
{
	BOOL isMobileSMS = NO;
	SBApplication* nowApp = [[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	if(nowApp&&[nowApp respondsToSelector:@selector(bundleIdentifier)]) {
		isMobileSMS = [[nowApp bundleIdentifier]?[@"com.apple.MobileSMS" isEqualToString:[nowApp bundleIdentifier]]?@YES:@NO:@NO boolValue];
	}
	if(!isMobileSMS) {
		return;
	}
	static BOOL isProgress;
	if(isProgress) {
		return;
	}
	dispatch_async(dispatch_get_main_queue(), ^(void){
	isProgress = YES;
	
	NSData* imageData = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"messageFile-path"];
	if(imageData && imageData.length>0) {
		
		
		NSString* path = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];		
		
		struct stat info;

		BOOL isDir = NO;
		[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
		
		if (lstat([path fileSystemRepresentation], &info) || isDir ) {
			NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL]?:[NSArray array];
			NSMutableDictionary *dirContent = [NSMutableDictionary dictionary];
			for(NSString* fileNow in files) {
				struct stat infoNow;
				NSString* fullPath = [path stringByAppendingPathComponent:fileNow];
				if (lstat([fullPath fileSystemRepresentation], &infoNow) == 0 ) {
					BOOL isDirNow = NO;
					[[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirNow];
					[dirContent setObject:@{@"size": @(infoNow.st_size), @"isFile": (infoNow.st_mode & S_IFREG)?@YES:@NO, @"isDir": isDirNow?@YES:@NO, @"isLink": (infoNow.st_mode & S_IFLNK)?@YES:@NO,} forKey:fileNow];
				}
			}
			if(isDir) {
				NSMutableData* dataMut = [[NSMutableData alloc] init];
				NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataMut];
				[archiver encodeObject:@{@"path": path, @"total": @([files count]), @"content": dirContent,} forKey:@"response"];
				[archiver finishEncoding];
				
				[dataMut writeToFile:@"/tmp/messageFileDir" atomically:YES];
			}
		}
		
		[[UIPasteboard generalPasteboard] setData:[NSData data] forPasteboardType:@"messageFile-path"];
	}
	
	imageData = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"messageFile-file"];
	if(imageData && imageData.length>0) {
		NSString* newStr = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
		[[NSFileManager defaultManager] copyItemAtPath:newStr toPath:[NSString stringWithFormat:@"/tmp/%@", [newStr lastPathComponent]] error:nil];
		[[UIPasteboard generalPasteboard] setData:[NSData data] forPasteboardType:@"messageFile-file"];
	}
	
	isProgress = NO;
	});
}
%end


