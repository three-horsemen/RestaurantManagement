CREATE TABLE [dbo].[Ingredients]
(
	[ingredient_id] INT NOT NULL PRIMARY KEY, 
    [ingredient_name] VARCHAR(50) NOT NULL, 
    [ingredient_price] DECIMAL NOT NULL,
	[ingredient_quantity] INT NOT NULL
)
