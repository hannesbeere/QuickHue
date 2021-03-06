//
//  DPQuickHuePresetStore.m
//  QuickHue
//
//  Created by Dan Parsons on 12/19/12.
//  Copyright (c) 2012 Dan Parsons. All rights reserved.
//

#import "DPQuickHuePresetStore.h"
#import "DPQuickHuePreset.h"

@interface DPQuickHuePresetStore ()
@property (nonatomic, strong) NSMutableArray *allPresets;
@end

@implementation DPQuickHuePresetStore

+ (DPQuickHuePresetStore *)sharedStore {
    static DPQuickHuePresetStore *sharedStore = nil;
    if (!sharedStore)
        sharedStore = [[super allocWithZone:nil] init];
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

- (id)init {
    self = [super init];
    if (self) {
        NSString *path = [self presetArchivePath];
        _allPresets = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!_allPresets)
            _allPresets = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)save {
    NSString *path = [self presetArchivePath];
    return [NSKeyedArchiver archiveRootObject:_allPresets toFile:path];
}

- (BOOL)nameUsed:(NSString *)name {
    for (DPQuickHuePreset *preset in self.allPresets) {
        if ([preset.name isEqualToString:name])
            return YES;
    }
    return NO;
}

- (NSString *)generateName {
    for (int i = 1; ; i++) {
        NSString *name = [NSString stringWithFormat:@"Preset %d", i];
        if (![self nameUsed:name])
            return name;
    }
}

- (DPQuickHuePreset *)createPreset {
    DPQuickHuePreset *p = [[DPQuickHuePreset alloc] init];
    p.name = [self generateName];
    [_allPresets addObject:p];
    return p;
}

- (NSArray *)allPresets {
    return _allPresets;
}

- (void)removePreset:(DPQuickHuePreset *)p {
    [_allPresets removeObjectIdenticalTo:p];
}

- (void)removePresetAtIndex:(int)i {
    [_allPresets removeObjectAtIndex:i];
}

- (void)setName:(NSString *)name atIndex:(int)i {
    DPQuickHuePreset *preset = _allPresets[i];
    preset.name = name;
}

- (NSString *)presetArchivePath {
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSArray *dirs = [fileMan URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL *appSupDir = dirs[0];
    NSString *path = [appSupDir.path stringByAppendingPathComponent:@"QuickHue"];
    if (![fileMan fileExistsAtPath:path]) {
        [fileMan createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [path stringByAppendingPathComponent:@"presets.archive"];
}

@end
