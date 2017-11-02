CREATE PROCEDURE [dbo].[ItemsData]
AS
	DELETE FROM Items;
	INSERT INTO Items(item_id, name, price)
	VALUES
	(1, 'Burger', 100),
	(2, 'Pizza', 150),
	(3, 'Milkshake', 90),
	(4, 'Sandwich', 80),
	(5, 'Fries', 50)
RETURN 0
