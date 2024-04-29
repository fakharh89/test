//
//  ASApplicationImage.m
//  Pods
//
//  Created by Michael Gordon on 1/22/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASApplicationImage.h"

#import "ASLog.h"

#define MAX_FIRMWARE_SIZE      0x10000 // 64 kBytes
#define Size_Of_Control_Header 6 // Size of Control Header in bytes
#define Size_Of_Block_Header   8 // Size of each Block Header in bytes

#define Size_of_Root           16
#define Size_Of_User_Keys      16

#define BT_MAC_Address_offset  2                           // Offset into data block for Mac address
#define XTAL_Trim_offset       8                           // Offset into data block for the crystal trim
#define IR_offset              60                          // Offset into data block for the identity root
#define ER_offset              IR_offset + Size_of_Root    // Offset into data block for the encryption root
#define UK_offset              16                          // Offset into data block for the user keys

#define Number_Of_Blocks       3   // byte - Number of Block Headers

@interface ASApplicationImage ()

@property (strong, readwrite, nonatomic) NSMutableData *binaryImage;
@property (assign, readwrite, nonatomic) uint8_t *CSKeys;

@end

@implementation ASApplicationImage

- (instancetype)initWithImagePath:(NSString *)imagePath {
    NSParameterAssert(imagePath);
    self = [super init];
    if (self) {
        _binaryImage = [self binaryImageFromImagePath:imagePath];
        _CSKeys = [self getCSKeys];
    }
    return self;
}

- (NSMutableData *)binaryImageFromImagePath:(NSString *)imagePath {
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:imagePath encoding:NSUTF8StringEncoding error:&error];
    
    if (!fileContents) {
        ASLog(@"Error loading image file: %@", error);
        return nil;
    }
    
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    uint32_t maxAddress=0;
    uint8_t rawData[MAX_FIRMWARE_SIZE];
    int32_t found = NO; // set to YES if at least one valid data byte found
    uint32_t address;    // storage hex string to binary conversion
    uint32_t data;
    // For all text lines in the file
    for (NSString *line in allLinedStrings) {
        // Make sure line begins with @, as it could begin with //
        // AND
        // Make sure 2 hex strings are decoded, address size is 6 chars and data size is 4 chars
        // Otherwise discard.
        if ([line UTF8String][0] == '@'
            && sscanf ([line UTF8String], "@%6x %4x", &address, &data) == 2) {
            found = YES;
            if (address > maxAddress) {
                maxAddress = address;
            }
            if (address < MAX_FIRMWARE_SIZE) {
                rawData[address] = data & 0xff;
                rawData[address + 1] = data >> 8;
            }
        }
    }
    
    NSMutableData *binaryFirmware = nil;
    if (found) {
        binaryFirmware = [[NSMutableData alloc] initWithBytes:rawData length:(maxAddress + 2)];
    }
    
    return binaryFirmware;
}

- (uint8_t *)getCSKeys {
    // Work out pointer to cs keys based on num blocks read from image.
    uint16_t *data = (uint16_t*)[self.binaryImage bytes];
    uint16_t numBlocks = CFSwapInt16BigToHost(data[1]);
    return (uint8_t*)[self.binaryImage mutableBytes] + Size_Of_Control_Header + (numBlocks * Size_Of_Block_Header);
}

- (void)updateCrystalTrim:(NSData *)crystalTrim {
    NSParameterAssert(crystalTrim);
    uint8_t *key = self.CSKeys + XTAL_Trim_offset;
    
    uint8_t *bytes = (uint8_t *) [crystalTrim bytes];
    
    int size = (int)[crystalTrim length];
    while (size--) {
        *key++ = *bytes++;
    }
}

- (void)updateMACAddress:(NSData *)MACAddress {
    NSParameterAssert(MACAddress);
    uint8_t *key = self.CSKeys + BT_MAC_Address_offset;
    
    uint8_t *bytes = (uint8_t *) [MACAddress bytes];
    
    // Have to copy bytes in reverse
    for (int i = 0, offset = 5; i < [MACAddress length]; i++, offset--) {
        *key++ = *(bytes + offset);
    }
}

- (void)updateIdentityRoot:(NSData *)identityRoot {
    NSParameterAssert(identityRoot);
    uint8_t *key = self.CSKeys + IR_offset;
    
    uint8_t *bytes = (uint8_t *) [identityRoot bytes];
    
    memcpy(key, bytes, Size_of_Root);
}

- (void)updateEncryptionRoot:(NSData *)encryptionRoot {
    NSParameterAssert(encryptionRoot);
    uint8_t *key = self.CSKeys + ER_offset;
    
    uint8_t *bytes = (uint8_t *) [encryptionRoot bytes];
    
    memcpy(key, bytes, Size_of_Root);
}

- (void)updateUserKeys:(NSData *)userKeys {
    NSParameterAssert(userKeys);
    uint8_t *key = self.CSKeys + UK_offset;
    
    uint8_t *bytes = (uint8_t *) [userKeys bytes];
    
    memcpy(key, bytes, Size_Of_User_Keys);
}

- (void)copyBytesFromSource:(uint8_t *)source toDestination:(uint8_t *)destination size:(int)size  {
    while (size--) {
        *destination++ = *source++;
    }
}

- (NSData *)applicationImageData {
    [self generateBlockCRC:0];
    [self generateHeaderCRC];
    
    return [NSData dataWithData:self.binaryImage];
}

- (void)generateBlockCRC:(int)block {
    uint16_t crcRemainder = 0;
    
    uint8_t *base;
    base = [self.binaryImage mutableBytes];
    
    // - Compute the start address of the given block.
    uint16_t *blockHeader = (uint16_t *) (base + Size_Of_Control_Header + (Size_Of_Block_Header * block));
    
    uint16_t src = *(blockHeader);
    uint16_t length = *(blockHeader+2);
    
    while (length--) {
        crcRemainder = [self addCRCRemainder:crcRemainder byte:*(base + src++)];
    }
    
    // - Store CRC
    *(blockHeader + 3) = crcRemainder;
}

- (void)generateHeaderCRC {
    uint16_t crcRemainder=0;
    
    uint8_t *base;
    base = [self.binaryImage mutableBytes];
    
    // - Compute size of Header Block
    uint16_t sizeOfHeaderBlock = (Size_Of_Control_Header + (*(base + Number_Of_Blocks) * Size_Of_Block_Header));
    
    // - Skip the first two bytes for the start of crc computation as this is where
    //   the crc is stored.
    uint16_t src = 2;
    
    // - length of crc block is 2 less than the size of the Header as we omit the
    //   space occupied by the crc
    uint16_t length = sizeOfHeaderBlock - 2;
    
    while (length--) {
        crcRemainder = [self addCRCRemainder:crcRemainder byte:*(base + src++)];
    }
    
    // The Header CRC is stored at the first word in memory therefore compute a
    // 16-bit pointer and save the crc there.
    uint16_t *controlHeader = (uint16_t *) base;
    *controlHeader = crcRemainder;
}

- (uint16_t)addCRCRemainder:(uint16_t)remainder byte:(uint8_t)byte {
    
    /* The CRC lookup table */
    const uint16_t crcLookupTable[] = {
        0x0000U, 0x8005U, 0x800FU, 0x000AU, 0x801BU, 0x001EU, 0x0014U, 0x8011U,
        0x8033U, 0x0036U, 0x003CU, 0x8039U, 0x0028U, 0x802DU, 0x8027U, 0x0022U,
        0x8063U, 0x0066U, 0x006CU, 0x8069U, 0x0078U, 0x807DU, 0x8077U, 0x0072U,
        0x0050U, 0x8055U, 0x805FU, 0x005AU, 0x804BU, 0x004EU, 0x0044U, 0x8041U,
        0x80C3U, 0x00C6U, 0x00CCU, 0x80C9U, 0x00D8U, 0x80DDU, 0x80D7U, 0x00D2U,
        0x00F0U, 0x80F5U, 0x80FFU, 0x00FAU, 0x80EBU, 0x00EEU, 0x00E4U, 0x80E1U,
        0x00A0U, 0x80A5U, 0x80AFU, 0x00AAU, 0x80BBU, 0x00BEU, 0x00B4U, 0x80B1U,
        0x8093U, 0x0096U, 0x009CU, 0x8099U, 0x0088U, 0x808DU, 0x8087U, 0x0082U,
        0x8183U, 0x0186U, 0x018CU, 0x8189U, 0x0198U, 0x819DU, 0x8197U, 0x0192U,
        0x01B0U, 0x81B5U, 0x81BFU, 0x01BAU, 0x81ABU, 0x01AEU, 0x01A4U, 0x81A1U,
        0x01E0U, 0x81E5U, 0x81EFU, 0x01EAU, 0x81FBU, 0x01FEU, 0x01F4U, 0x81F1U,
        0x81D3U, 0x01D6U, 0x01DCU, 0x81D9U, 0x01C8U, 0x81CDU, 0x81C7U, 0x01C2U,
        0x0140U, 0x8145U, 0x814FU, 0x014AU, 0x815BU, 0x015EU, 0x0154U, 0x8151U,
        0x8173U, 0x0176U, 0x017CU, 0x8179U, 0x0168U, 0x816DU, 0x8167U, 0x0162U,
        0x8123U, 0x0126U, 0x012CU, 0x8129U, 0x0138U, 0x813DU, 0x8137U, 0x0132U,
        0x0110U, 0x8115U, 0x811FU, 0x011AU, 0x810BU, 0x010EU, 0x0104U, 0x8101U,
        0x8303U, 0x0306U, 0x030CU, 0x8309U, 0x0318U, 0x831DU, 0x8317U, 0x0312U,
        0x0330U, 0x8335U, 0x833FU, 0x033AU, 0x832BU, 0x032EU, 0x0324U, 0x8321U,
        0x0360U, 0x8365U, 0x836FU, 0x036AU, 0x837BU, 0x037EU, 0x0374U, 0x8371U,
        0x8353U, 0x0356U, 0x035CU, 0x8359U, 0x0348U, 0x834DU, 0x8347U, 0x0342U,
        0x03C0U, 0x83C5U, 0x83CFU, 0x03CAU, 0x83DBU, 0x03DEU, 0x03D4U, 0x83D1U,
        0x83F3U, 0x03F6U, 0x03FCU, 0x83F9U, 0x03E8U, 0x83EDU, 0x83E7U, 0x03E2U,
        0x83A3U, 0x03A6U, 0x03ACU, 0x83A9U, 0x03B8U, 0x83BDU, 0x83B7U, 0x03B2U,
        0x0390U, 0x8395U, 0x839FU, 0x039AU, 0x838BU, 0x038EU, 0x0384U, 0x8381U,
        0x0280U, 0x8285U, 0x828FU, 0x028AU, 0x829BU, 0x029EU, 0x0294U, 0x8291U,
        0x82B3U, 0x02B6U, 0x02BCU, 0x82B9U, 0x02A8U, 0x82ADU, 0x82A7U, 0x02A2U,
        0x82E3U, 0x02E6U, 0x02ECU, 0x82E9U, 0x02F8U, 0x82FDU, 0x82F7U, 0x02F2U,
        0x02D0U, 0x82D5U, 0x82DFU, 0x02DAU, 0x82CBU, 0x02CEU, 0x02C4U, 0x82C1U,
        0x8243U, 0x0246U, 0x024CU, 0x8249U, 0x0258U, 0x825DU, 0x8257U, 0x0252U,
        0x0270U, 0x8275U, 0x827FU, 0x027AU, 0x826BU, 0x026EU, 0x0264U, 0x8261U,
        0x0220U, 0x8225U, 0x822FU, 0x022AU, 0x823BU, 0x023EU, 0x0234U, 0x8231U,
        0x8213U, 0x0216U, 0x021CU, 0x8219U, 0x0208U, 0x820DU, 0x8207U, 0x0202U
    };
    
    uint8_t data;
    
    data = ([self reflectByte:byte]) ^ ((uint8_t)(remainder >> 8));
    remainder = crcLookupTable[data] ^ (remainder << 8);
    return remainder;
}

- (uint8_t)reflectByte:(uint8_t)byte  {
    uint8_t refelectedByte = 0;
    
    for (int i = 0; i < 8; i++) {
        refelectedByte <<= 1;
        if (byte & 1) {
            refelectedByte |= 1;
        }
        byte >>= 1;
    }
    
    return refelectedByte;
}

@end
