CREATE PROCEDURE [dbo].[IngredientsData]
AS
	DELETE FROM Ingredients;
	INSERT INTO Ingredients(ingredient_id, ingredient_name, ingredient_price)
	VALUES
	(1, 'Salt', 10),
	(2,	'Bread', 50),
	(3,	'Sugar', 15),
	(4,	'Milk', 20),
	(5,	'Chili', 5),
	(6,	'Onion', 10),
	(7,	'Cheese', 15),
	(8,	'Capsicum', 30),
	(9,	'Potato', 25),
	(10, 'Pepper', 10)
RETURN 0
