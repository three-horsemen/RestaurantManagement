CREATE PROCEDURE [dbo].[IngredientsData]
AS
	DELETE FROM Ingredients;
	INSERT INTO Ingredients(ingredient_id, ingredient_name, ingredient_price, ingredient_quantity)
	VALUES
	(1, 'Salt', 10, 8),
	(2,	'Bread', 50, 8),
	(3,	'Sugar', 15, 8),
	(4,	'Milk', 20, 8),
	(5,	'Chili', 5, 8),
	(6,	'Onion', 10, 8),
	(7,	'Cheese', 15, 8),
	(8,	'Capsicum', 30, 8),
	(9,	'Potato', 25, 8),
	(10, 'Pepper', 10, 8)
RETURN 0
