CREATE PROCEDURE [dbo].[OrdersData]
AS
	DELETE FROM Orders;
	INSERT INTO Orders(order_id, item_id, quantity, total_price, timestamp)
	VALUES
	(1, 1, 3, 300, '2017-11-02'),
	(2, 2, 4, 600, '2017-11-01'),
	(2, 3, 10, 900, '2017-10-20'),
	(3, 4, 10, 1000, '2017-10-01')
RETURN 0