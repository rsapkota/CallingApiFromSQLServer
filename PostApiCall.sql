USE [master]
GO

/****** Object:  StoredProcedure [dbo].[usp_CallPostApiAndProcessResponse]    Script Date: 7/27/2023 5:17:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_CallPostApiAndProcessResponse]
    @name NVARCHAR(100),
    @job NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Enable Ole Automation Procedures (if not already enabled)
    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE;
    EXEC sp_configure 'Ole Automation Procedures', 1;
    RECONFIGURE;

    -- Declare variables
    DECLARE @url VARCHAR(500) = 'https://reqres.in/api/users';
    DECLARE @httpRequest INT, @responseText VARCHAR(8000), @statusCode INT;

    -- Build JSON Payload dynamically using parameters
    DECLARE @jsonPayload NVARCHAR(MAX) = N'{
        "name": "' + REPLACE(@name, '"', '""') + '",
        "job": "' + REPLACE(@job, '"', '""') + '"
    }';

    -- Create HTTP request object
    EXEC sp_OACreate 'MSXML2.ServerXMLHTTP', @httpRequest OUT;
    IF @httpRequest <> 0
    BEGIN
        -- Set HTTP request properties for POST method
        EXEC sp_OAMethod @httpRequest, 'open', NULL, 'POST', @url, false;
        EXEC sp_OAMethod @httpRequest, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
    
        -- Send the JSON payload in the request body
        EXEC sp_OAMethod @httpRequest, 'send', NULL, @jsonPayload;

        -- Get the HTTP status code
        EXEC sp_OAGetProperty @httpRequest, 'status', @statusCode OUT;

        IF @statusCode = 201
        BEGIN
            -- Get the response text
            EXEC sp_OAGetProperty @httpRequest, 'responseText', @responseText OUT;

            -- Close the HTTP request object
            EXEC sp_OADestroy @httpRequest;

            -- Process the API response (deserialize JSON)
            SELECT *
            FROM OPENJSON(@responseText) 
            WITH (
                id INT '$.id',
                name NVARCHAR(100) '$.name',
                job NVARCHAR(100) '$.job',
                createdAt NVARCHAR(50) '$.createdAt'
            ) AS ApiResponseData;
        END
        ELSE
        BEGIN
            -- Close the HTTP request object
            EXEC sp_OADestroy @httpRequest;

            -- Output status code for non-200 responses
            SELECT @statusCode AS StatusCode;
        END
    END
END
GO

