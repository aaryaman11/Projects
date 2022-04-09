package Roll_a_Dice;

import java.util.Random;

public class Roll_Dice {
    public static void main(String[] args) {
        // need to create a randomizer number
        // store the number and print it
        Random num = new Random();
        int min = 1;
        int max = 6;
        int z = num.nextInt(max) + min;
        System.out.println("You Rolled a " + z);
    }
}
