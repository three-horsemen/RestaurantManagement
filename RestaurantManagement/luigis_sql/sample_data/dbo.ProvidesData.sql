CREATE PROCEDURE [dbo].[ProvidesData]
AS
	DELETE FROM Provides;
	INSERT INTO Provides(ingredient_id, ingredient_quantity, timestamp)
	VALUES
	(1, 50, '2017-11-02'),
	(2, 50, '2017-10-12'),
	(3, 50, '2017-10-02'),
	(4, 50, '2017-11-01'),
	(5, 50, '2017-11-01'),
	(6, 50, '2017-11-01'),
	(7, 50, '2017-09-02'),
	(8, 50, '2017-09-02'),
	(9, 50, '2017-09-02'),
	(10, 50, '2016-11-02')
RETURN 0
