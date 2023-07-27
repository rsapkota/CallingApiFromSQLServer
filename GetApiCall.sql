USE [master]
GO

/****** Object:  StoredProcedure [dbo].[usp_GetUsersFromAPI]    Script Date: 7/27/2023 5:24:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_GetUsersFromAPI]
    @page INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Enable Ole Automation Procedures (if not already enabled)
    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE;
    EXEC sp_configure 'Ole Automation Procedures', 1;
    RECONFIGURE;

    -- Declare variables
    DECLARE @url VARCHAR(500) = 'https://reqres.in/api/users?page=' + CAST(@page AS VARCHAR(10));
    DECLARE @httpRequest INT, @responseText VARCHAR(8000);

    -- Create HTTP request object
    EXEC sp_OACreate 'MSXML2.ServerXMLHTTP', @httpRequest OUT;
    IF @httpRequest <> 0
    BEGIN
        -- Set HTTP request properties
        EXEC sp_OAMethod @httpRequest, 'open', NULL, 'GET', @url, false;
        EXEC sp_OAMethod @httpRequest, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
        EXEC sp_OAMethod @httpRequest, 'send', NULL, '';

        -- Get the response text
        EXEC sp_OAGetProperty @httpRequest, 'responseText', @responseText OUT;

        -- Close the HTTP request object
        EXEC sp_OADestroy @httpRequest;
    END

    -- Deserialize JSON response and select only "data" property
    SELECT data.*
    FROM OPENJSON(@responseText, '$.data') 
    WITH (
        id INT '$.id',
        email NVARCHAR(100) '$.email',
        first_name NVARCHAR(50) '$.first_name',
        last_name NVARCHAR(50) '$.last_name',
        avatar NVARCHAR(200) '$.avatar'
    ) AS data;
END
GO


