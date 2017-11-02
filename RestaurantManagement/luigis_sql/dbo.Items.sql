DROP TABLE [dbo].[Items];
CREATE TABLE [dbo].[Items]
(
	[item_id] INT NOT NULL PRIMARY KEY, 
    [name] VARCHAR(50) NOT NULL, 
    [price] DECIMAL NOT NULL
)
