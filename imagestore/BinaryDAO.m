//
//  BinaryDAO.m
//  imagestore
//
//  Created by oddman on 11/1/15.
//  Copyright © 2015 oddman. All rights reserved.
//

#import "BinaryDAO.h"
#import "sqlite3.h"

@implementation BinaryDAO {
}

- (instancetype) initWithPath:(NSString *)path {
    if (self = [super init]) {
        _fullDbPath = path;
    }
    return self;
}

- (void) createBinaryDB {
    sqlite3 * db = NULL;
    char *errmsg = NULL;

    //NSString * documentPath = [self dbFilePath];
    //fileExist = [[NSFileManager alloc] fileExistsAtPath:documentPath];

    if (!(sqlite3_open([_fullDbPath UTF8String], &db) == SQLITE_OK)) {
        NSLog(@"An error has occured.");
    } else {
        const char *sqlTable = "create table if not exists binaryTbl(ID integer primary key, fileName varchar, binaryData blob)";
        if (sqlite3_exec(db, sqlTable, NULL, NULL, &errmsg) != SQLITE_OK) {
            NSLog(@"There is a problem with statement %s", errmsg);
            sqlite3_free(errmsg);
        }
        sqlite3_close(db);
    }
}

- (void) insertBinaryData:(NSData*)binData binName:(NSString*)binName {
    sqlite3 *db = NULL;
    sqlite3_stmt *sqlStatement = NULL;
    do {
        if (!(sqlite3_open([_fullDbPath UTF8String], &db) == SQLITE_OK)) {
            NSLog(@"An error has occurred.");
            break;
        }

        const char *insertSQL = "Insert into binaryTbl(fileName, binaryData) VALUES(?,?);";

        if (sqlite3_prepare_v2(db, insertSQL, -1, &sqlStatement, NULL) != SQLITE_OK) {
            NSLog(@"Problem with prepare statement");
            break;
        }
        sqlite3_bind_text(sqlStatement, 1, [binName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_blob(sqlStatement, 2, [binData bytes], (int)[binData length], SQLITE_TRANSIENT);

        if(sqlite3_step(sqlStatement)==SQLITE_DONE){
        }
        
    } while (NO);

    if (sqlStatement) {
        sqlite3_finalize(sqlStatement);
    }
    sqlite3_close(db);
}

- (NSMutableArray*) selectBinaryStoredList {
    sqlite3 *db = NULL;
    NSMutableArray *storedBinaryList = [[NSMutableArray alloc]init];
    @try {
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString * dbPath = _fullDbPath;

        BOOL success = [fileMgr fileExistsAtPath:dbPath];
        if (!success) {
            NSLog(@"Cannot locate database file '%@'.", dbPath);
        }

        if (!(sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK)) {
            NSLog(@"An error has occured.");
        }

        NSString * sqlQry = @"SELECT * FROM  binaryTbl";

        sqlite3_stmt *sqlStatement;
        if (sqlite3_prepare_v2(db, [sqlQry UTF8String], -1, &sqlStatement, NULL) != SQLITE_OK) {
            NSLog(@"Problem with prepare statement: %d", sqlite3_errcode(db));
        }

        while (sqlite3_step(sqlStatement)==SQLITE_ROW) {
            NSString * viewFilename = [ NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStatement, 1)];
            NSLog(@"This is the filename %@", viewFilename);
            [storedBinaryList addObject:viewFilename];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"An exception occurred: %@", [exception reason]);
    }
    @finally {
        sqlite3_close(db);
        return storedBinaryList;
    }
}


- (NSData*) displaySelectedFile:(NSString*)selectedFile {
    sqlite3 *db = NULL;

    NSData *image = [[NSData alloc]init];

    @try {
        NSFileManager *fileMgr = [NSFileManager defaultManager];

        NSString * dbPath = _fullDbPath;

        BOOL success = [fileMgr fileExistsAtPath:dbPath];
        if (!success) {
            NSLog(@"Cannot locate database file '%@'.", dbPath);
        }

        if (!(sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK)) {
            NSLog(@"An error has occurred.");
        }

        NSString *sql=[NSString stringWithFormat: @"SELECT binaryData FROM binaryTbl where fileName= \"%@\"", selectedFile];

        sqlite3_stmt *sqlStatement = NULL;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &sqlStatement, NULL) != SQLITE_OK) {
            NSLog(@"Problem with prepare statement");
        }

        while (sqlite3_step(sqlStatement)==SQLITE_ROW) {
            const char *raw = sqlite3_column_blob(sqlStatement, 0);
            int rawLen = sqlite3_column_bytes(sqlStatement, 0);
            image = [NSData dataWithBytes:raw length:rawLen];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"An exception occurred: %@", [exception reason]);
    }
    @finally {
        sqlite3_close(db);
        return image;
    }
}

int deleteCallback (void *p, int n, char **i, char **e) {
    return 0;
}

- (BOOL) deleteSelectedFile:(NSString *)selectedFile {
    BOOL succ = NO;
    sqlite3 *db = NULL;
    sqlite3_stmt *sqlStatement = NULL;
    @try {
        if (![[NSFileManager defaultManager] fileExistsAtPath:_fullDbPath]) {
            NSLog(@"Cannot locate database file '%@'.", _fullDbPath);
            return succ;
        }
        if (!(sqlite3_open([_fullDbPath UTF8String], &db) == SQLITE_OK)) {
            NSLog(@"An error has occurred.");
            return succ;
        }
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM binaryTbl WHERE fileName = '%@';", selectedFile];

#if 1
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &sqlStatement, NULL) != SQLITE_OK) {
            return succ;
            NSLog(@"Problem with prepare statement");
        }
        int s = sqlite3_step(sqlStatement);
        if (s != SQLITE_DONE) {
            return succ;
        }
#else
        int s = sqlite3_exec(db, [sql UTF8String], deleteCallback, (__bridge void *)(self), nil);
        if (s != SQLITE_OK) {
            return succ;
        }
#endif
        succ = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"An exception occurred: %@", [exception reason]);
    }
    @finally {
        if (sqlStatement) {
            sqlite3_finalize(sqlStatement);
        }
        sqlite3_close(db);
    }
    return succ;
}

@end
