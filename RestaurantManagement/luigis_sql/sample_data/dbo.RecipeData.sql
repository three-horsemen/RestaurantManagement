﻿CREATE PROCEDURE [dbo].[RecipeData]
AS
	DELETE FROM Recipe;
	INSERT INTO Recipe(item_id, ingredient_id, ingredient_quantity)
	VALUES
	(1, 2, 1),
	(1, 5, 2),
	(1, 6, 1),
	(1, 8, 2),
	(1, 10, 5),
	(2, 1, 2),
	(2, 2, 4),
	(2, 5, 5),
	(2, 6, 3),
	(2, 7, 5),
	(2, 8, 2),
	(2, 10, 2),
	(3, 3, 8),
	(3, 4, 4),
	(4, 2, 2),
	(4, 5, 1),
	(4, 6, 1),
	(4, 7, 1),
	(4, 8, 1),
	(4, 9, 1),
	(5, 1, 5),
	(5, 9, 3)
RETURN 0
