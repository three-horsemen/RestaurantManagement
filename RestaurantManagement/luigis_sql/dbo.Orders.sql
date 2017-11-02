DROP TABLE [dbo].[Orders];
CREATE TABLE [dbo].[Orders]
(
	[order_id] INT NOT NULL , 
    [timestamp] DATE NOT NULL, 
    [item_id] INT NOT NULL, 
    [quantity] INT NOT NULL, 
    [total_price] DECIMAL NOT NULL 
)
