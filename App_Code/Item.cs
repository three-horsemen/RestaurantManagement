using System.Collections.Generic;

public class Item
{
    public class IngredientQty
    {
        public IngredientQty(Ingredient ingredient, float qty)
        {
            this.ingredient = ingredient;
            this.qty = qty;
        }
        public Ingredient ingredient;
        public float qty;
    }

    public static Item burger = new Item(1, "Burger", 210, new List<IngredientQty>() {
        new IngredientQty(Ingredient.bread, 1),
        new IngredientQty(Ingredient.cheese, 0.1f),
        new IngredientQty(Ingredient.pepper, 0.01f)
    });
    public static Item pizza = new Item(1, "Pizza", 210, new List<IngredientQty>() {
        new IngredientQty(Ingredient.bread, 0.5f),
        new IngredientQty(Ingredient.cheese, 0.1f)
    });
    public static Item milkshake = new Item(1, "Milk Shake", 210, new List<IngredientQty>() {
        new IngredientQty(Ingredient.milk, 0.1f),
        new IngredientQty(Ingredient.butter, 0.05f)
    });

    public static List<Item> items = new List<Item>() { burger, pizza, milkshake };

    public Item(int code, string name, float price, List<IngredientQty> ingredients)
    {
        this.code = code;
        this.name = name;
        this.price = price;
        this.ingrQty = ingredients;
    }
    public int code;
    public string name;
    public float price;
    public List<IngredientQty> ingrQty;
}