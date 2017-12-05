
//
//  Database.m
//  DbExample
//
//  Created by mac on 08/02/16.
//  Copyright © 2016 mac. All rights reserved.
//

#import "Database.h"

static Database *db;
@implementation Database

+(Database *)shareddatabase
{
    if(!db)
    {
        db=[[Database alloc]init];
        return db;
    }
    else
    {
        return db;
    }
}

-(id)init
{
    if (!db)
    {
        db=[super init];
        
    }
    else
    {
        @throw [NSException exceptionWithName:@"invalid method called" reason:@"use shareddatabase method" userInfo:NULL];
    }
    return db;
}

-(NSString *)getDatabasePath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Cube_DB.sqlite"];
}



-(void)insertDepartMentData:(NSArray*)deptArray
{
    for (int i=0; i<deptArray.count; i++)
    {
        DepartMent* deptObj= [deptArray objectAtIndex:i];
        NSString *query3=[NSString stringWithFormat:@"INSERT INTO DepartMentList values(\"%ld\",\"%@\")",deptObj.Id,deptObj.departmentName];
        
        Database *db=[Database shareddatabase];
        NSString *dbPath=[db getDatabasePath];
        sqlite3_stmt *statement;
        sqlite3* feedbackAndQueryTypesDB;
        
        
        const char * queryi3=[query3 UTF8String];
        if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
        {
            sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
            if(sqlite3_step(statement)==SQLITE_DONE)
            {
               // NSLog(@"report data inserted");
               // NSLog(@"%@",NSHomeDirectory());
                sqlite3_reset(statement);
            }
            else
            {
               // NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
            }
        }
        else
        {
            //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
        
        if (sqlite3_finalize(statement) == SQLITE_OK)
        {
            //NSLog(@"statement is finalized");
        }
        else
           // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        
        
        if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
        {
            //NSLog(@"db is closed");
        }
        else
        {
            //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
        

    }
    
    
    
    }

-(void)insertTaskIdentifier:(NSString*)taskIdentifier fileName:(NSString*)fileName
{
        NSString *query3=[NSString stringWithFormat:@"INSERT OR REPLACE INTO TaskIdentifier values(\"%@\",\"%@\")",taskIdentifier,fileName];
    //NSString *query3=[NSString stringWithFormat:@"Delete from TaskIdentifier Where TASKID like '%%%@%%'",@"Xanadutec"];

        Database *db=[Database shareddatabase];
        NSString *dbPath=[db getDatabasePath];
        sqlite3_stmt *statement;
        sqlite3* feedbackAndQueryTypesDB;
        
        
        const char * queryi3=[query3 UTF8String];
        if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
        {
            sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
            if(sqlite3_step(statement)==SQLITE_DONE)
            {
                // NSLog(@"report data inserted");
                // NSLog(@"%@",NSHomeDirectory());
                sqlite3_reset(statement);
            }
            else
            {
                //[[Database shareddatabase] insertTaskIdentifier:taskIdentifier fileName:fileName];
                 NSLog(@"error while inserting task id:%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
            }
        }
        else
        {
            NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
        
        if (sqlite3_finalize(statement) == SQLITE_OK)
        {
            NSLog(@"statement is finalized");
        }
        else
        {
         
        }
            // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
            
            
            if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
            {
                //NSLog(@"db is closed");
            }
            else
            {
                //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
            }
        
    
}


-(NSString*)getfileNameFromTaskIdentifier:(NSString*)taskIdentifier
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    NSString* companyId;
    sqlite3* feedbackAndQueryTypesDB;
    //NSMutableArray* departmentNameArray=[[NSMutableArray alloc]init];;
    NSString *query3=[NSString stringWithFormat:@"Select FILENAME from TaskIdentifier Where TASKID='%@'",taskIdentifier];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                companyId=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
               // [departmentNameArray addObject:companyId];
                
            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
    {
    }
    //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return companyId;
}

-(void)deleteIdentifierFromDatabase:(NSString*)identifier
{
    
    NSString *query3=[NSString stringWithFormat:@"Delete from TaskIdentifier Where TASKID='%@'",identifier];
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    
    
    const char * queryi3=[query3 UTF8String];
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
    {
        sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
            //NSLog(@"report data inserted");
            //NSLog(@"%@",NSHomeDirectory());
            sqlite3_reset(statement);
        }
        else
        {
            //NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    
    else
    {
        //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        // NSLog(@"statement is finalized");
    }
    else
        // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
        
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    
}



-(void) createFileNameidentifierRelationshipTable
{
    Database *db=[Database shareddatabase];
    NSString *dbPathString=[db getDatabasePath];
     const char *dbpath = [dbPathString UTF8String];
    sqlite3* feedbackAndQueryTypesDB;
    if (sqlite3_open(dbpath, &feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = "CREATE TABLE IF NOT EXISTS TaskIdentifier (TASKID TEXT PRIMARY KEY , FILENAME TEXT)";
        
        if (sqlite3_exec(feedbackAndQueryTypesDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            NSLog(@"TaskIdentifier created" );
        }
        sqlite3_close(feedbackAndQueryTypesDB);
    }
    else
    {
       
    }

}

-(NSMutableArray*)getDepartMentNames
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    NSString* companyId;
    sqlite3* feedbackAndQueryTypesDB;
    NSMutableArray* departmentNameArray=[[NSMutableArray alloc]init];;
    NSString *query3=[NSString stringWithFormat:@"Select DepartMentName from DepartMentList"];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
               companyId=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                [departmentNameArray addObject:companyId];
                
            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
    {
    }
        //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }

    
    return departmentNameArray;
}


-(NSString*)getfileNameFromDictationID:(NSString*)mobileDictationIdVal
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    NSString* companyId;
    sqlite3* feedbackAndQueryTypesDB;
    //NSMutableArray* departmentNameArray=[[NSMutableArray alloc]init];;
    NSString *query3=[NSString stringWithFormat:@"Select RecordItemName from CubeData Where mobileDictationIdVal=%d",[mobileDictationIdVal intValue]];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                companyId=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                // [departmentNameArray addObject:companyId];
                
            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
    {
    }
    //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return companyId;
}
-(DepartMent*)getDepartMentFromDepartmentName:(NSString*)name
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    DepartMent* obj=[[DepartMent alloc]init];

    NSString *query3=[NSString stringWithFormat:@"Select * from DepartMentList Where DepartMentName='%@'",name];

    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                obj.Id=sqlite3_column_int(statement, 0);

                obj.departmentName=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)];
                
            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
    {
    }
       // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
       // NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return obj;
}

-(int)getCountOfTransfersOfDicatationStatus:(NSString*)status//for failed transfer might be
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    int count;
    NSString *query3;
    if ([status isEqualToString:@"RecordingComplete"])
    {
        query3=[NSString stringWithFormat:@"Select Count(RecordItemName) from CubeData Where DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@') or DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@') and (TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@') or TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@') or TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@'))",status,@"RecordingFileUpload",@"NotTransferred",@"Resend",@"ResendFailed"];
    }
    else
    query3=[NSString stringWithFormat:@"Select Count(RecordItemName) from CubeData Where DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@')",status];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
              //  count=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
              count=  sqlite3_column_int(statement, 0);
                
            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
       // NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
    {
    }  // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return count;
}

-(int)getCountOfTodaysTransfer:(NSString*)dateAndTimeString
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    int count;
    
    NSArray* dateAndTimeArray=[dateAndTimeString componentsSeparatedByString:@" "];
    
    dateAndTimeString=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:0]];
    NSString *query3=[NSString stringWithFormat:@"Select Count(RecordItemName) from CubeData Where TransferStatus=(Select Id from TransferStatus Where TransferStatus='Transferred') and TransferDate LIKE '%@%%'",dateAndTimeString];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                //  count=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                count=  sqlite3_column_int(statement, 0);
                
            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
       // NSLog(@"statement is finalized");
    }
    else
    {
    }
       //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return count;

}


-(int)getCountOfTransferFailed
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    int count;
    NSString *query3=[NSString stringWithFormat:@"Select Count(RecordItemName) from CubeData Where TransferStatus=(Select Id from TransferStatus Where TransferStatus='TransferFailed')"];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                //  count=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                count=  sqlite3_column_int(statement, 0);
                
            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
        //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return count;
}

//RecordItemName,RecordCreatedDate,DepartmentName

-(NSMutableArray*)getListOfFileTransfersOfStatus:(NSString*)status
{
  
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement,*statement1,*statement2,*statement3,*statement4;
    sqlite3* feedbackAndQueryTypesDB;
    NSMutableDictionary* dict=[[NSMutableDictionary alloc]init];
    NSMutableArray* listArray=[[NSMutableArray alloc]init];
    NSString* RecordItemName,*RecordCreatedDate,*Department,*TransferStatus,*CurrentDuration,*transferDate,*deleteStatus,*dictationStatus;
    NSString *query3;
    NSString* dateAndTimeString= [[APIManager sharedManager] getDateAndTimeString];
    NSArray* dateAndTimeArray=[dateAndTimeString componentsSeparatedByString:@" "];
    
    dateAndTimeString=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:0]];

    if ([status isEqualToString:@"Transferred"])
    {
               query3=[NSString stringWithFormat:@"Select RecordItemName,RecordCreateDate,Department,TransferStatus,CurrentDuration,TransferDate,DeleteStatus,DictationStatus from CubeData Where TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@') and TransferDate LIKE '%@%%'",status,dateAndTimeString];

    }
    else

        if ([status isEqualToString:@"RecordingComplete"])
        {

    query3=[NSString stringWithFormat:@"Select RecordItemName,RecordCreateDate,Department,TransferStatus,CurrentDuration,TransferDate,DeleteStatus,DictationStatus from CubeData Where DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@') or DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@') and (TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@') or TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@')  or TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@'))",status,@"RecordingFileUpload",@"NotTransferred",@"Resend",@"ResendFailed"];
        }
    
    else
        if ([status isEqualToString:@"TransferFailed"])
        {
         query3=[NSString stringWithFormat:@"Select RecordItemName,RecordCreateDate,Department,TransferStatus,CurrentDuration,TransferDate,DeleteStatus,DictationStatus from CubeData Where TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@')",status];
    
        }
    else
        if ([status isEqualToString:@"RecordingPause"])
        {
            
            query3=[NSString stringWithFormat:@"Select RecordItemName,RecordCreateDate,Department,TransferStatus,CurrentDuration,TransferDate,DeleteStatus,DictationStatus from CubeData Where DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@')",status];
        }

    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                  RecordItemName=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                RecordCreatedDate=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)];
                Department=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                TransferStatus=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                CurrentDuration=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 4)];
                transferDate=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 5)];
                deleteStatus=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 6)];
                dictationStatus=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 7)];

                NSString *query4=[NSString stringWithFormat:@"Select DepartMentName from DepartMentList Where Id='%@'",Department];

                    if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query4 UTF8String], -1, &statement1, NULL) == SQLITE_OK)// 2. Prepare the query
                    {
                        while (sqlite3_step(statement1) == SQLITE_ROW)
                        {
                            Department=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement1, 0)];
                        }
                    }
                    else
                    {
                       // NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                    }
                
                    if (sqlite3_finalize(statement1) == SQLITE_OK)
                    {
                      //NSLog(@"statement1 is finalized");
                    }
                    else
                    {}
                     //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));

                
                
                
                NSString *query5=[NSString stringWithFormat:@"Select TransferStatus from TransferStatus Where Id='%@'",TransferStatus];
                
                if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query5 UTF8String], -1, &statement2, NULL) == SQLITE_OK)// 2. Prepare the query
                {
                    while (sqlite3_step(statement2) == SQLITE_ROW)
                    {
                        TransferStatus=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement2, 0)];
                    }
                }
                else
                {
//                    NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
                
                if (sqlite3_finalize(statement2) == SQLITE_OK)
                {
//                    NSLog(@"statement1 is finalized");
                }
                else
//                    NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                {}
                
                
                NSString *query6=[NSString stringWithFormat:@"Select DeleteStatus from DeleteStatus Where Id='%@'",deleteStatus];
                
                if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query6 UTF8String], -1, &statement3, NULL) == SQLITE_OK)// 2. Prepare the query
                {
                    while (sqlite3_step(statement3) == SQLITE_ROW)
                    {
                        deleteStatus=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement3, 0)];
                    }
                }
                else
                {
//                    NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
                
                if (sqlite3_finalize(statement3) == SQLITE_OK)
                {
//                    NSLog(@"statement1 is finalized");
                }
                else
//                    NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                {}
               
                
                NSString *query7=[NSString stringWithFormat:@"Select RecordingStatus from DictationStatus Where Id='%@'",dictationStatus];
                
                if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query7 UTF8String], -1, &statement4, NULL) == SQLITE_OK)// 2. Prepare the query
                {
                    while (sqlite3_step(statement4) == SQLITE_ROW)
                    {
                        dictationStatus=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement4, 0)];
                    }
                }
                else
                {
//                    NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
                
                if (sqlite3_finalize(statement4) == SQLITE_OK)
                {
                   // NSLog(@"statement1 is finalized");
                }
                else
                    //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                {}
                
                
                dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:RecordItemName,@"RecordItemName",RecordCreatedDate,@"RecordCreatedDate",Department,@"Department",TransferStatus,@"TransferStatus",CurrentDuration,@"CurrentDuration",transferDate,@"TransferDate",deleteStatus,@"DeleteStatus",dictationStatus,@"DictationStatus",nil];
                [listArray addObject:dict];
            }
            
            
        }
        else
        {
           // NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
        //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {}
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
       // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    // sorting for latest date file on top

    
    NSDictionary*  headerObj1=[[NSDictionary alloc]init];
    NSDictionary*  headerObj2=[[NSDictionary alloc]init];
    NSDictionary*  temp=[[NSDictionary alloc]init];
    NSComparisonResult result;
    
    for (int i=0; i<listArray.count; i++)
    {
        for (int j=1; j<listArray.count-i; j++)
        {
            headerObj1= [listArray objectAtIndex:j-1];
            headerObj2=  [listArray objectAtIndex:j];
            result=[[headerObj1 valueForKey:@"RecordCreatedDate" ] compare:[headerObj2 valueForKey:@"RecordCreatedDate" ]];
            if (result==NSOrderedAscending)
            {
                temp=[listArray objectAtIndex:j-1];
                [listArray replaceObjectAtIndex:j-1 withObject:[listArray objectAtIndex:j]];
                [listArray replaceObjectAtIndex:j withObject:temp];
                
            }
        }
    }

    return listArray;

}

-(NSString*)getDepartMentIdFromDepartmentName:(NSString*)departmentName
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    NSString* departmentId;
    NSString *query3=[NSString stringWithFormat:@"Select Id from DepartMentList Where DepartMentName='%@'",departmentName];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                  departmentId=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                
            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
       // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
       // NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return departmentId;

}

-(NSString*)getDefaultDepartMentId
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    NSString* departmentId;
    NSMutableArray* departmentArray=[NSMutableArray new];
    NSString *query3=[NSString stringWithFormat:@"Select Id from DepartMentList"];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                departmentId=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                [departmentArray addObject:departmentId];
                
            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
        // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        // NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
//
    if (departmentArray.count>0)
    {
        departmentId=[NSString stringWithFormat:@"%@",[departmentArray objectAtIndex:0]];
        return  departmentId;
    }
    else
    return 0;
    
}

-(int)getDepartMentIdForFileName:(NSString*)fileName;
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    int departmentId;
    NSString *query3=[NSString stringWithFormat:@"Select Department from CubeData Where RecordItemName='%@'",fileName];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
//                departmentId=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                departmentId=sqlite3_column_int(statement, 0);

                
            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
        // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        // NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return departmentId;


}
-(void)insertRecordingData:(NSDictionary*)dict;
{
    
                NSString *query3=[NSString stringWithFormat:@"INSERT INTO CubeData values(\"%@\",\"%@\",\"%@\",\"%@\",\"%d\",\"%d\",\"%d\",\"%@\",\"%@\",\"%@\",\"%d\",\"%d\",\"%d\",\"%@\")",[dict valueForKey:@"recordItemName"],[dict valueForKey:@"recordCreatedDate"],[dict valueForKey:@"recordingDate"],[dict valueForKey:@"transferDate"],[[dict valueForKey:@"dictationStatus"]intValue],[[dict valueForKey:@"transferStatus"]intValue],[[dict valueForKey:@"deleteStatus"]intValue],[dict valueForKey:@"deleteDate"],[dict valueForKey:@"fileSize"],[dict valueForKey:@"currentDuration"],[[dict valueForKey:@"newDataUpdate"]intValue],[[dict valueForKey:@"newDataSend"]intValue],[[dict valueForKey:@"mobileDictationIdVal"]intValue],[dict valueForKey:@"departmentName"]];
    
                Database *db=[Database shareddatabase];
                NSString *dbPath=[db getDatabasePath];
                sqlite3_stmt *statement;
                sqlite3* feedbackAndQueryTypesDB;
    
    
                const char * queryi3=[query3 UTF8String];
                if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
                {
                    sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
                    if(sqlite3_step(statement)==SQLITE_DONE)
                    {
                        //NSLog(@"report data inserted");
                        //NSLog(@"%@",NSHomeDirectory());
                        sqlite3_reset(statement);
                    }
                    else
                    {
                        //NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                    }
                }
                else
                {
                    //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
    
                if (sqlite3_finalize(statement) == SQLITE_OK)
                {
                    //NSLog(@"statement is finalized");
                }
                else
                    //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                {}
    
                if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
                {
                    //NSLog(@"db is closed");
                }
                else
                {
                    //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }

}


-(void)updateAudioFileName:(NSString*)existingAudioFileName dictationStatus:(NSString*)status;
{
    
    NSString *query3=[NSString stringWithFormat:@"Update CubeData set DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@') Where RecordItemName='%@'",status,existingAudioFileName];
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    
    
    const char * queryi3=[query3 UTF8String];
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
    {
      sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
      if(sqlite3_step(statement)==SQLITE_DONE)
        {
           // NSLog(@"report data inserted");
            //NSLog(@"%@",NSHomeDirectory());
            sqlite3_reset(statement);
        }
        else
        {
            //NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    
    else
    {
        //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
   // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
       // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
                


}

-(void)updateAudioFileName:(NSString*)existingAudioFileName duration:(float)duration;
{
    
    NSString *query3=[NSString stringWithFormat:@"Update CubeData set CurrentDuration=%f Where RecordItemName='%@'",duration,existingAudioFileName];
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    
    
    const char * queryi3=[query3 UTF8String];
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
    {
        sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
            //NSLog(@"report data inserted");
            //NSLog(@"%@",NSHomeDirectory());
            sqlite3_reset(statement);
        }
        else
        {
            //NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    
    else
    {
        //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
        //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {}
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
       // NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }

}


-(NSMutableArray*)getListOfTransferredOrDeletedFiles:(NSString*)listName
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement,*statement1,*statement2;
    sqlite3* feedbackAndQueryTypesDB;
    NSMutableDictionary* dict=[[NSMutableDictionary alloc]init];
    NSMutableArray* listArray=[[NSMutableArray alloc]init];
    NSString* RecordItemName,*Date,*Department,*RecordCreateDate,*status,*transferDate;
    NSString* query3,*statusQuery;
    if ([listName isEqual:@"Transferred"])
    {
        query3=[NSString stringWithFormat:@"Select RecordItemName,TransferDate,Department,RecordCreateDate,DeleteStatus,TransferDate from CubeData Where TransferStatus=(Select Id from TransferStatus Where TransferStatus='Transferred') and DeleteStatus!=%d",1];
        
        statusQuery=[NSString stringWithFormat:@"Select DeleteStatus from DeleteStatus Where Id='%@'",status];
    }
    if ([listName isEqual:@"Deleted"])
    {
        query3=[NSString stringWithFormat:@"Select RecordItemName,DeleteDate,Department,RecordCreateDate,TransferStatus,TransferDate from CubeData Where DeleteStatus=1"];
        statusQuery=[NSString stringWithFormat:@"Select TransferStatus from TransferStatus Where Id='%@'",status];

    }
//    NSString *query3=[NSString stringWithFormat:@"Select RecordItemName,RecordCreateDate,Department,TransferStatus,CurrentDuration from CubeData Where DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@')",status];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                RecordItemName=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                Date=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)];
                Department=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                RecordCreateDate=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                status=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 4)];
                transferDate=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 5)];

                NSString *query4=[NSString stringWithFormat:@"Select DepartMentName from DepartMentList Where Id='%@'",Department];
                
                if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query4 UTF8String], -1, &statement1, NULL) == SQLITE_OK)// 2. Prepare the query
                {
                    while (sqlite3_step(statement1) == SQLITE_ROW)
                    {
                        Department=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement1, 0)];
                    }
                }
                else
                {
                    //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
                
                if (sqlite3_finalize(statement1) == SQLITE_OK)
                {
                    //NSLog(@"statement1 is finalized");
                }
                else
                    //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                {}
                
                if ([listName isEqual:@"Transferred"])
                {
                    statusQuery=[NSString stringWithFormat:@"Select DeleteStatus from DeleteStatus Where Id='%@'",status];
                }
                if ([listName isEqual:@"Deleted"])
                {
                    statusQuery=[NSString stringWithFormat:@"Select TransferStatus from TransferStatus Where Id='%@'",status];
                    
                }

                if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [statusQuery UTF8String], -1, &statement2, NULL) == SQLITE_OK)// 2. Prepare the query
                {
                    while (sqlite3_step(statement2) == SQLITE_ROW)
                    {
                        status=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement2, 0)];
                    }
                }
                else
                {
                    //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
                
                if (sqlite3_finalize(statement2) == SQLITE_OK)
                {
                   // NSLog(@"statement1 is finalized");
                }
                else
                   // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                {
                }
                
                dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:RecordItemName,@"RecordItemName",Date,@"Date",Department,@"Department",RecordCreateDate,@"RecordCreateDate",status,@"status",transferDate,@"TransferDate", nil];
                [listArray addObject:dict];
            }
            
            
        }
        else
        {
           // NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
       // NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
       // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {}
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
       // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    // sorting for latest date file on top
    
    
    NSDictionary*  headerObj1=[[NSDictionary alloc]init];
    NSDictionary*  headerObj2=[[NSDictionary alloc]init];
    NSDictionary*  temp=[[NSDictionary alloc]init];
    NSComparisonResult result;
    
    for (int i=0; i<listArray.count; i++)
    {
        for (int j=1; j<listArray.count-i; j++)
        {
            headerObj1= [listArray objectAtIndex:j-1];
            headerObj2=  [listArray objectAtIndex:j];
            result=[[headerObj1 valueForKey:@"Date" ] compare:[headerObj2 valueForKey:@"Date" ]];
            if (result==NSOrderedAscending)
            {
                temp=[listArray objectAtIndex:j-1];
                [listArray replaceObjectAtIndex:j-1 withObject:[listArray objectAtIndex:j]];
                [listArray replaceObjectAtIndex:j withObject:temp];
                
            }
        }
    }

    return listArray;
    

}


-(void)updateAudioFileStatus:(NSString*)status fileName:(NSString*)fileName dateAndTime:(NSString*)dateAndTimeString;
{
    
    NSString *query3=[NSString stringWithFormat:@"Update CubeData set DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@'),DeleteStatus=1,DeleteDate='%@' Where RecordItemName='%@'",status,dateAndTimeString,fileName];
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    
    
    const char * queryi3=[query3 UTF8String];
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
    {
        sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
            //NSLog(@"report data inserted");
            //NSLog(@"%@",NSHomeDirectory());
            sqlite3_reset(statement);
        }
        else
        {
            //NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    
    else
    {
        //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
       // NSLog(@"statement is finalized");
    }
    else
       // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
    
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    
}

-(void)deleteFileRecordFromDatabase:(NSString*)fileName
{
    
    NSString *query3=[NSString stringWithFormat:@"Delete from CubeData Where RecordItemName='%@'",fileName];
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    
    
    const char * queryi3=[query3 UTF8String];
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
    {
        sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
            //NSLog(@"report data inserted");
            //NSLog(@"%@",NSHomeDirectory());
            sqlite3_reset(statement);
        }
        else
        {
            //NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    
    else
    {
        //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        // NSLog(@"statement is finalized");
    }
    else
        // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
        
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    
}
-(void)updateAudioFileUploadedStatus:(NSString*)status fileName:(NSString*)fileName dateAndTime:(NSString*)dateAndTimeString mobiledictationidval:(long) idval;
{
    
    NSString *query3=[NSString stringWithFormat:@"Update CubeData set TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@'),TransferDate='%@',mobiledictationidval=%ld Where RecordItemName='%@'",status,dateAndTimeString,idval,fileName];
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    
    
    const char * queryi3=[query3 UTF8String];
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
    {
        sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
           // NSLog(@"report data inserted");
            //NSLog(@"%@",NSHomeDirectory());
            sqlite3_reset(statement);
        }
        else
        {
           // NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    
    else
    {
        //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
        //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {}
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
       // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    
}



-(void)updateAudioFileStatus:(NSString*)status fileName:(NSString*)fileName
{
    
    NSString *query3=[NSString stringWithFormat:@"Update CubeData set DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@') Where RecordItemName='%@'",status,fileName];
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    
    
    const char * queryi3=[query3 UTF8String];
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
    {
        sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
           // NSLog(@"report data inserted");
           // NSLog(@"%@",NSHomeDirectory());
            sqlite3_reset(statement);
        }
        else
        {
           // NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    
    else
    {
       // NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
    {
        NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
       // NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    
}


-(void)updateDownloadingStatus:(int)downloadStatus dictationId:(int)dictationId
{
    
    NSString *query3=[NSString stringWithFormat:@"Update CubeData set NewDataSend=%d Where mobiledictationidval=%d",downloadStatus,dictationId];
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    
    
    const char * queryi3=[query3 UTF8String];
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
    {
        sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
           // NSLog(@"report data inserted");
           // NSLog(@"%@",NSHomeDirectory());
            sqlite3_reset(statement);
        }
        else
        {
           // NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    
    else
    {
       // NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
       // NSLog(@"statement is finalized");
    }
    else
        //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
       // NSLog(@"db is closed");
    }
    else
    {
       // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
}

-(int)getMobileDictationIdFromFileName:(NSString*)fileName;
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    int mobiledictationidval;
    NSString *query3=[NSString stringWithFormat:@"Select mobiledictationidval from CubeData Where RecordItemName='%@'",fileName];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
//                departmentId=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                mobiledictationidval=sqlite3_column_int(statement, 0);

            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
       // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {}
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
       // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return mobiledictationidval;
    
}


-(void)updateUploadingFileDictationStatus
{
    
    
    NSString *query3=[NSString stringWithFormat:@"Update CubeData set DictationStatus=1 Where TransferStatus=0 and DictationStatus=4 and NewDataUpdate!=%d ",5];// to set uploadfilestatus back to RecordingComplete when app get killed: for awaiting transfer
    
    NSString *query4=[NSString stringWithFormat:@"Update CubeData set TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@'),DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@') Where TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@') and DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@')",@"Transferred",@"RecordingFileUploaded",@"Resend",@"RecordingFileUpload"];// for resend transfer
    
    NSString *query5=[NSString stringWithFormat:@"Update CubeData set DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@') Where TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@') and DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@') and NewDataUpdate = %d ",@"RecordingFileUploaded",@"NotTransferred",@"RecordingFileUpload",5];//for imported transfer
    
    
    NSString *query6=[NSString stringWithFormat:@"Update CubeData set TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@') Where TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@') and DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@') ",@"TransferFailed",@"ResendFailed",@"RecordingFileUpload"];// to set uploadfilestatus back to transferfailed when app get killed: for failed transfer

    NSString *query7=[NSString stringWithFormat:@"Update CubeData set NewDataSend=%d Where NewDataSend=%d",NODOWNLOAD,DOWNLOADING];
    
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement,*statement1,*statement2,*statement3,*statement4;
    sqlite3* feedbackAndQueryTypesDB;
    
    const char * queryi3=[query3 UTF8String];
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
    {
        sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
           // NSLog(@"report data inserted");
           // NSLog(@"%@",NSHomeDirectory());
            sqlite3_reset(statement);
        }
        else
        {
            //NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    
    else
    {
        //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
       // NSLog(@"statement is finalized");
    }
    else
      //  NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {}
    
    
    //
    const char * queryi4=[query4 UTF8String];
    
    sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi4, -1, &statement1, NULL);
    if(sqlite3_step(statement1)==SQLITE_DONE)
    {
        // NSLog(@"report data inserted");
        // NSLog(@"%@",NSHomeDirectory());
        sqlite3_reset(statement1);
    }
    else
    {
        // NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    if (sqlite3_finalize(statement1) == SQLITE_OK)
    {
        // NSLog(@"statement1 is finalized");
    }
    else
    {}
    

       const char * queryi5=[query5 UTF8String];
    
    sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi5, -1, &statement2, NULL);
    if(sqlite3_step(statement2)==SQLITE_DONE)
    {
        // NSLog(@"report data inserted");
        // NSLog(@"%@",NSHomeDirectory());
        sqlite3_reset(statement2);
    }
    else
    {
        // NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    if (sqlite3_finalize(statement2) == SQLITE_OK)
    {
        // NSLog(@"statement1 is finalized");
    }
    else
    {}

    
    const char * queryi6=[query6 UTF8String];
    
    sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi6, -1, &statement3, NULL);
    if(sqlite3_step(statement3)==SQLITE_DONE)
    {
        // NSLog(@"report data inserted");
        // NSLog(@"%@",NSHomeDirectory());
        sqlite3_reset(statement3);
    }
    else
    {
        // NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    if (sqlite3_finalize(statement3) == SQLITE_OK)
    {
        // NSLog(@"statement1 is finalized");
    }
    else
    {}

    const char * queryi7=[query7 UTF8String];
    
    sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi7, -1, &statement4, NULL);
    if(sqlite3_step(statement4)==SQLITE_DONE)
    {
        // NSLog(@"report data inserted");
        // NSLog(@"%@",NSHomeDirectory());
        sqlite3_reset(statement4);
    }
    else
    {
        // NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    if (sqlite3_finalize(statement4) == SQLITE_OK)
    {
        // NSLog(@"statement1 is finalized");
    }
    else
    {}
       // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    //
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
       // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
   // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:APPLICATION_TERMINATE_CALLED];
 
}
-(void)updateUploadingStuckedStatus
{
     NSString *query3=[NSString stringWithFormat:@"Update CubeData set DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@'),TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@') Where DictationStatus=(Select Id from DictationStatus Where RecordingStatus='%@') and TransferStatus !=(Select Id from TransferStatus Where TransferStatus='%@')",@"RecordingComplete",@"NotTransferred",@"RecordingFileUpload",@"Transferred"];
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    
    
    const char * queryi3=[query3 UTF8String];
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
    {
        sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
            // NSLog(@"report data inserted");
            // NSLog(@"%@",NSHomeDirectory());
            sqlite3_reset(statement);
        }
        else
        {
            //NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    
    else
    {
        //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        // NSLog(@"statement is finalized");
    }
    else
        //  NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {}
    
    //
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }


}



-(int)getTransferStatus:(NSString*)fileName
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    int transferStatus;
    NSString *query3=[NSString stringWithFormat:@"Select TransferStatus from CubeData Where RecordItemName='%@'",fileName];
    
    if(sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                //                departmentId=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                transferStatus=sqlite3_column_int(statement, 0);
                
            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
        // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {}
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return transferStatus;

}


-(void)updateDepartment:(long)deptId fileName:(NSString*)fileName
{
    
    NSString *query3=[NSString stringWithFormat:@"Update CubeData set Department=%ld Where RecordItemName='%@'",deptId,fileName];
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    
    
    const char * queryi3=[query3 UTF8String];
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
    {
        sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
            // NSLog(@"report data inserted");
            // NSLog(@"%@",NSHomeDirectory());
            sqlite3_reset(statement);
        }
        else
        {
            // NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    
    else
    {
        // NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        // NSLog(@"statement is finalized");
    }
    else
        //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        // NSLog(@"db is closed");
    }
    else
    {
        // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
}


-(int)getImportedFileCount
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    int transferStatus;
    NSString *query3=[NSString stringWithFormat:@"Select Count(*) from CubeData Where newDataUpdate=%d",5];
    
    if(sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                //                departmentId=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                transferStatus=sqlite3_column_int(statement, 0);
                
            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
        // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {}
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return transferStatus;
    
}



-(void)getlistOfimportedFilesAudioDetailsArray:(int) newDataUpdate
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement,*statement1;
    sqlite3* feedbackAndQueryTypesDB;
    int departmentId;
    AppPreferences* app=[AppPreferences sharedAppPreferences];

    NSString *TransferStatus,*CurrentDuration,*transferDate,*deleteStatus,*dictationStatus,* recordItemName,*recordCreateDate,*Department;
    NSMutableDictionary* dict=[[NSMutableDictionary alloc]init];
    app.importedFilesAudioDetailsArray=[[NSMutableArray alloc]init];
    NSString *query3=[NSString stringWithFormat:@"Select RecordItemName,RecordCreateDate,Department,TransferStatus,CurrentDuration,TransferDate,DeleteStatus,DictationStatus from CubeData Where NewDataUpdate=%d and TransferStatus=(Select Id from TransferStatus Where TransferStatus='%@') and DeleteStatus=0 and (DictationStatus !=(Select Id from DictationStatus Where RecordingStatus='%@') and DictationStatus !=(Select Id from DictationStatus Where RecordingStatus='%@'))",newDataUpdate,@"NotTransferred",@"RecordingFileUpload",@"RecordingPause"];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                recordItemName=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                recordCreateDate=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)];

                departmentId=sqlite3_column_int(statement, 2);
                TransferStatus=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                CurrentDuration=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 4)];
                transferDate=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 5)];
                deleteStatus=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 6)];
                dictationStatus=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 7)];
                
                
                
                NSString *query4=[NSString stringWithFormat:@"Select DepartMentName from DepartMentList Where Id=%d",departmentId];
                
                if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query4 UTF8String], -1, &statement1, NULL) == SQLITE_OK)// 2. Prepare the query
                {
                    while (sqlite3_step(statement1) == SQLITE_ROW)
                    {
                        Department=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement1, 0)];
                    }
                }
                else
                {
                    // NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
                
                if (sqlite3_finalize(statement1) == SQLITE_OK)
                {
                    //NSLog(@"statement1 is finalized");
                }
                else
                {}
                //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                
                
                
                
                NSString *query5=[NSString stringWithFormat:@"Select TransferStatus from TransferStatus Where Id='%@'",TransferStatus];
                
                if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query5 UTF8String], -1, &statement1, NULL) == SQLITE_OK)// 2. Prepare the query
                {
                    while (sqlite3_step(statement1) == SQLITE_ROW)
                    {
                        TransferStatus=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement1, 0)];
                    }
                }
                else
                {
                    //                    NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
                
                if (sqlite3_finalize(statement1) == SQLITE_OK)
                {
                    //                    NSLog(@"statement1 is finalized");
                }
                else
                    //                    NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                {}
                
                
                NSString *query6=[NSString stringWithFormat:@"Select DeleteStatus from DeleteStatus Where Id='%@'",deleteStatus];
                
                if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query6 UTF8String], -1, &statement1, NULL) == SQLITE_OK)// 2. Prepare the query
                {
                    while (sqlite3_step(statement1) == SQLITE_ROW)
                    {
                        deleteStatus=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement1, 0)];
                    }
                }
                else
                {
                    //                    NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
                
                if (sqlite3_finalize(statement1) == SQLITE_OK)
                {
                    //                    NSLog(@"statement1 is finalized");
                }
                else
                    //                    NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                {}
                
                
                NSString *query7=[NSString stringWithFormat:@"Select RecordingStatus from DictationStatus Where Id='%@'",dictationStatus];
                
                if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query7 UTF8String], -1, &statement1, NULL) == SQLITE_OK)// 2. Prepare the query
                {
                    while (sqlite3_step(statement1) == SQLITE_ROW)
                    {
                        dictationStatus=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement1, 0)];
                    }
                }
                else
                {
                    //                    NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
                
                if (sqlite3_finalize(statement1) == SQLITE_OK)
                {
                    // NSLog(@"statement1 is finalized");
                }
                else
                    //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                {}
                dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:recordItemName,@"RecordItemName",recordCreateDate,@"RecordCreatedDate",Department,@"Department",TransferStatus,@"TransferStatus",CurrentDuration,@"CurrentDuration",transferDate,@"TransferDate",deleteStatus,@"DeleteStatus",dictationStatus,@"DictationStatus",nil];
                [app.importedFilesAudioDetailsArray addObject:dict];

            }
        }
        else
        {
            NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
        // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        // NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    //sorting for latest date file on top
    NSDictionary*  headerObj1=[[NSDictionary alloc]init];
    NSDictionary*  headerObj2=[[NSDictionary alloc]init];
    NSDictionary*  temp=[[NSDictionary alloc]init];
    NSComparisonResult result;
    
    for (int i=0; i<app.importedFilesAudioDetailsArray.count; i++)
    {
        for (int j=1; j<app.importedFilesAudioDetailsArray.count-i; j++)
        {
            headerObj1= [app.importedFilesAudioDetailsArray objectAtIndex:j-1];
            headerObj2=  [app.importedFilesAudioDetailsArray objectAtIndex:j];
            result=[[headerObj1 valueForKey:@"RecordCreatedDate" ] compare:[headerObj2 valueForKey:@"RecordCreatedDate" ]];
            if (result==NSOrderedAscending)
            {
                temp=[app.importedFilesAudioDetailsArray objectAtIndex:j-1];
                [app.importedFilesAudioDetailsArray replaceObjectAtIndex:j-1 withObject:[app.importedFilesAudioDetailsArray objectAtIndex:j]];
                [app.importedFilesAudioDetailsArray replaceObjectAtIndex:j withObject:temp];
                
            }
        }
    }

    
    
}


-(void)updateAudioFileDeleteStatus:(NSString*)status fileName:(NSString*)fileName updatedDated:(NSString*)updatedDated currentDuration:(NSString*)currentDuration fileSize:(NSString*) fileSize
{
    
    NSString *query3=[NSString stringWithFormat:@"Update CubeData set DeleteStatus=(Select Id from DeleteStatus Where DeleteStatus='%@'),RecordCreateDate='%@',currentduration='%@',FileSize='%@' Where RecordItemName='%@'",status,updatedDated,currentDuration,fileSize,fileName];
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    
    
    const char * queryi3=[query3 UTF8String];
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
    {
        sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
            // NSLog(@"report data inserted");
            // NSLog(@"%@",NSHomeDirectory());
            sqlite3_reset(statement);
        }
        else
        {
            // NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    
    else
    {
        // NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        // NSLog(@"statement is finalized");
    }
    else
        // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        // NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    
}



-(void)setDepartment
{
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    NSString* departmentId,*recordItemName;
    NSMutableArray* recordItemNameArray=[NSMutableArray new];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];

    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSString* defaultDepartId=[[Database shareddatabase] getDepartMentIdFromDepartmentName:deptObj.departmentName];
    NSString *query3=[NSString stringWithFormat:@"Select RecordItemName from CubeData Where Department='0'"];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                recordItemName=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                
                [recordItemNameArray addObject:recordItemName];
                

            }
        }
        else
        {
            //NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
        // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    {
    }
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        // NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    for (int i=0; i<recordItemNameArray.count; i++)
    {
        NSString *query4=[NSString stringWithFormat:@"Update CubeData set Department=%d Where RecordItemName='%@'",[defaultDepartId intValue],[NSString stringWithFormat:@"%@",[recordItemNameArray objectAtIndex:i]]];
        
        if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
        {
            const char * queryi3=[query4 UTF8String];
            if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
            {
                sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
                if(sqlite3_step(statement)==SQLITE_DONE)
                {
                    // NSLog(@"report data inserted");
                    //NSLog(@"%@",NSHomeDirectory());
                    sqlite3_reset(statement);
                }
                else
                {
                    NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
            }
            
            else
            {
                //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
            }
            
            if (sqlite3_finalize(statement) == SQLITE_OK)
            {
                //NSLog(@"statement is finalized");
            }
            else
                // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
            {
            }
        }
        if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
        {
            //NSLog(@"db is closed");
        }
        else
        {
            // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
        

    }
    
}


-(void)addDictationStatus:(NSString*)dictationStatus
{

    NSString *query3=[NSString stringWithFormat:@"INSERT INTO DictationStatus values(\"%d\",\"%@\")",5,dictationStatus];
            
            Database *db=[Database shareddatabase];
            NSString *dbPath=[db getDatabasePath];
            sqlite3_stmt *statement;
            sqlite3* feedbackAndQueryTypesDB;
            
            
            const char * queryi3=[query3 UTF8String];
            if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
            {
                sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
                if(sqlite3_step(statement)==SQLITE_DONE)
                {
                    // NSLog(@"report data inserted");
                    // NSLog(@"%@",NSHomeDirectory());
                    sqlite3_reset(statement);
                }
                else
                {
                    // NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
            }
            else
            {
                //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
            }
            
            if (sqlite3_finalize(statement) == SQLITE_OK)
            {
                //NSLog(@"statement is finalized");
            }
            else
            {
             
            }
                // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                
                
                if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
                {
                    //NSLog(@"db is closed");
                }
                else
                {
                    //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
                }
            
}


-(NSArray*) getFilesToBePurged
{
 
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement,*statement1;
    NSString* recordItemName, *date;
    sqlite3* feedbackAndQueryTypesDB;
    NSMutableArray* filesToBePurgedArray = [[NSMutableArray alloc]init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    
    
    //NSDate* todaysDate = [NSDate new];
    NSString* purgeDeleteDataKey =  [[NSUserDefaults standardUserDefaults] valueForKey:PURGE_DELETED_DATA];
    
    NSArray* daysArray = [purgeDeleteDataKey componentsSeparatedByString:@" "];
    
    NSString* daysString;
    
    if (daysArray.count>0)
    {
        daysString = [daysArray objectAtIndex:0];
    }
  //  NSDate *purgeDataDate = [[NSDate date] dateByAddingTimeInterval:-[daysString intValue]*24*60*60];
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = -[daysString intValue];
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
//    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];

    NSLog(@"nextDate: %@ ...", nextDate);
   // NSDate *purgeDataDate = [[NSDate date] dateByAddingTimeInterval:-5*24*60*60];

    
    formatter.dateFormat = @"MM-dd-yyyy";
    
    NSString* newDate = [formatter stringFromDate:nextDate];

    NSString *query3=[NSString stringWithFormat:@"Select RecordItemName,TransferDate from CubeData Where TransferStatus = 1 and DeleteStatus = 0 and TransferDate < '%@'",newDate];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                recordItemName=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                
                date=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)];

                [filesToBePurgedArray addObject:recordItemName];
                
            }
        }
        else
        {
            NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
    {
    }
    
    
    NSString *query4=[NSString stringWithFormat:@"Select RecordItemName,DeleteDate from CubeData Where DeleteStatus = 1 and DeleteDate < '%@'",newDate];
    
    
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query4 UTF8String], -1, &statement1, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement1) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                recordItemName=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement1, 0)];
                
                date=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement1, 1)];
                
                [filesToBePurgedArray addObject:recordItemName];
                
            }
        }
        else
        {
            NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
   
    
    if (sqlite3_finalize(statement1) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
    {
    }

    //NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return filesToBePurgedArray;

}

-(NSArray*) getUploadedFilesDictationIdList
{
    
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    NSMutableArray* uploadedFilesDictationIdArray = [[NSMutableArray alloc]init];
    int dictationId = 0;
    
    
    NSString *query3=[NSString stringWithFormat:@"Select mobiledictationidval from CubeData Where TransferStatus = 1 and DeleteStatus = 0"];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                
                dictationId = sqlite3_column_int(statement, 0);
                
                [uploadedFilesDictationIdArray addObject:[NSString stringWithFormat:@"%d",dictationId]];
                
            }
        }
        else
        {
            NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
    {
    }
    
    
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return uploadedFilesDictationIdArray;
    
}

-(NSArray*) getUploadedFileList
{
    
    Database *db=[Database shareddatabase];
    NSString *dbPath=[db getDatabasePath];
    sqlite3_stmt *statement;
    sqlite3* feedbackAndQueryTypesDB;
    NSMutableArray* uploadedFilesArray = [[NSMutableArray alloc]init];
    
    
    
    NSString *query3=[NSString stringWithFormat:@"Select RecordItemName,TransferDate, mobiledictationidval, CurrentDuration, FileSize, Department, NewDataSend from CubeData Where TransferStatus = 1 and DeleteStatus = 0"];
    
    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB) == SQLITE_OK)// 1. Open The DataBase.
    {
        if (sqlite3_prepare_v2(feedbackAndQueryTypesDB, [query3 UTF8String], -1, &statement, NULL) == SQLITE_OK)// 2. Prepare the query
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                // [app.feedOrQueryDetailMessageArray addObject:[NSString stringWithUTF8String:message]];
                AudioDetails* audioDetails = [[AudioDetails alloc] init];
                
                audioDetails.fileName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                
                audioDetails.transferDate = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)];
                
                audioDetails.mobiledictationidval = sqlite3_column_int(statement, 2);

                audioDetails.currentDuration = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];

                audioDetails.fileSize = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 4)];

                audioDetails.department = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 5)];

                audioDetails.downloadStatus =  sqlite3_column_int(statement, 6);

                [uploadedFilesArray addObject:audioDetails];
                
            }
        }
        else
        {
            NSLog(@"Can't preapre query due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
        }
    }
    else
    {
        //NSLog(@"can't open db due error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    if (sqlite3_finalize(statement) == SQLITE_OK)
    {
        //NSLog(@"statement is finalized");
    }
    else
    {
    }
    
    
    
    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
    {
        //NSLog(@"db is closed");
    }
    else
    {
        //NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
    }
    
    
    return uploadedFilesArray;
    
}
//-(void)updateAudioFileName
//{
//    
//    NSString *query3=[NSString stringWithFormat:@"Update CubeData set TransferDate='02-21-2017 17:25:20'"];
//    Database *db=[Database shareddatabase];
//    NSString *dbPath=[db getDatabasePath];
//    sqlite3_stmt *statement;
//    sqlite3* feedbackAndQueryTypesDB;
//    
//    
//    const char * queryi3=[query3 UTF8String];
//    if (sqlite3_open([dbPath UTF8String], &feedbackAndQueryTypesDB)==SQLITE_OK)
//    {
//        sqlite3_prepare_v2(feedbackAndQueryTypesDB, queryi3, -1, &statement, NULL);
//        if(sqlite3_step(statement)==SQLITE_DONE)
//        {
//            // NSLog(@"report data inserted");
//            //NSLog(@"%@",NSHomeDirectory());
//            sqlite3_reset(statement);
//        }
//        else
//        {
//            //NSLog(@"%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
//        }
//    }
//    
//    else
//    {
//        //NSLog(@"errormsg=%s",sqlite3_errmsg(feedbackAndQueryTypesDB));
//    }
//    
//    if (sqlite3_finalize(statement) == SQLITE_OK)
//    {
//        //NSLog(@"statement is finalized");
//    }
//    else
//        // NSLog(@"Can't finalize due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
//    {
//    }
//    
//    if (sqlite3_close(feedbackAndQueryTypesDB) == SQLITE_OK)
//    {
//        //NSLog(@"db is closed");
//    }
//    else
//    {
//        // NSLog(@"Db is not closed due to error = %s",sqlite3_errmsg(feedbackAndQueryTypesDB));
//    }
//    
//    
//    
//}


@end
