Step 1: Open file PostApiCall.sql and execute it in your Sql Server. This will create a SP that you can later execute with parameter for making POST Api call.

Step 2: Open file GetApiCall.sql and execute it in your Sql Server. This will create a SP that you can later execute with parameter for making GET Api call. 

Usuage: 
1. Execute your POST SP using below example : 
              EXEC [dbo].[usp_CallPostApiAndProcessResponse] @name = 'morpheus', @job = 'leader';

2. Execute your GET SP using below example : 
                EXEC [dbo].[usp_GetUsersFromAPI] @page = 1


