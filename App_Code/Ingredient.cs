using System.Collections.Generic;

public class Ingredient
{
    public static Ingredient salt = new Ingredient("Salt", 70, 10);
    public static Ingredient pepper = new Ingredient("Pepper", 80, 10);
    public static Ingredient bread = new Ingredient("Bread", 30, 10);
    public static Ingredient butter = new Ingredient("Butter", 40, 10);
    public static Ingredient cheese = new Ingredient("Cheese", 100, 10);
    public static Ingredient milk = new Ingredient("Milk", 20, 10);

    List<Ingredient> items = new List<Ingredient>() { salt, pepper, bread, butter, cheese, milk};

    public Ingredient(string name, float price, float currQty)
    {
        this.name = name;
        this.price = price;
        this.currQty = currQty;
    }
    public string name;
    public float price;
    public float currQty;
}