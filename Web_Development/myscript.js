function myfunction(){
    document.getElementById("demo").innerHTML= "Testing JavaScript";
    alert("Testing JS")

    let a, b, c;
    a=5;b=7;c=a+b;
    document.getElementById("demo1").innerHTML= c;
    // const values are immutable
{
    let carName = "Audi";
    document.getElementById("demo2").innerHTML = carName;
}
{
    const cars = ["Audi ", " BMW", " Volvo"];
    cars[0] = "Nissan";
    cars.push(" KIA");
    document.getElementById('demo3').innerHTML= cars;

}
{
    const car1 = {type:"Fiat", model:"500", color:"white"};
    car1.color = "red";
    car1.owner = "Jack"
    document.getElementById('demo4').innerHTML= "The color of the car is " + car1.color + " and the owner of the car is " + car1.owner; 
}
{
    let x = 5;
    x += 7;
    document.getElementById('demo5').innerHTML = x;
}
{
    let z = BigInt("123456789012345678901234567890");
    document.getElementById('demo6').innerHTML = z;
}
{
    let x= 5;
    let y = 5;
    let z = 9;
    document.getElementById('demo7').innerHTML = (x==y) +"<br>"+(y==z);
}
{
    var k = myfunction(5,4);
    document.getElementById('demo8').innerHTML = k;
    function myfunction(a,b){
        return a*b;
    }
}
{
    const person={
        Firstname:"Joe",
        Lastname: "Jackson",
        id: 3489,
        fullname:function(){
            return this.Firstname + " " + this.Lastname;
        }

    };
    document.getElementById('demo9').innerHTML=person.fullname()
}
{
    let text = "We are the so-called \'Vikings\' from the north.";
    document.getElementById("demo10").innerHTML = text; 
}

{
    let text1 = "5";
    document.getElementById('demo12').innerHTML=text1.padStart(4,'x');
}
{
    var j  ="Hello World";
    document.getElementById('demo13').innerHTML = j.charAt(0);
}
{
    let text3 = `He's often called "Johnny"`;
    document.getElementById("demo14").innerHTML = text3;
}
{
    let firstName = "John";
    let lastName = "Doe";

    let text = `Welcome ${firstName}, ${lastName}!`;
    document.getElementById('demo15').innerHTML = text;
}
}
function myfunction1(){
    let text = document.getElementById('demo11').innerHTML;
    document.getElementById('demo11').innerHTML = text.replace('Microsoft', 'W3School');

    {
        let x = "100";
        let y = "10";
        let z = x / y;   // this will work and will not be considered as a string
        document.getElementById("demo16").innerHTML = z;
    }
    {
        let x = BigInt(999999999);
        document.getElementById('demo17').innerHTML = typeof x;
    }
    {
        const fruits = ["Pineapple", "Apple", "Mango", "Watermellon"];
        fruits[4] = "Banana";
        let len = fruits.length;
        let txt = "<ul>" 
        for (i=0; i < len; i++){
            txt += "<li>" + fruits[i] + "</li>";
        }
        txt += "<ul>"
        document.getElementById('demo18').innerHTML = txt;
    }
    {
        const fruits = ["Pineapple", "Apple", "Mango", "Watermellon"];
        document.getElementById('demo19').innerHTML = fruits.join("*");
    }
    {
        const fruits = ["Pineapple", "Apple", "Mango", "Watermellon"];
        fruits.shift();
        document.getElementById('demo20').innerHTML = fruits;
        
    }
    {
        const fruits = ["Pineapple", "Apple", "Mango", "Watermellon"];
        fruits.unshift("Lemon");
        document.getElementById('demo21').innerHTML = fruits;
    }
    /*deleting from array can leave unefined holes-->https://www.w3schools.com/js/js_array_methods.asp*/
    {
        const array1 = ["Cecilie", "Lone"];
        const array2 = ["Emil", "Tobias", "Linus"];
        const array3 = ["Robin", "Morgan"];
        document.getElementById('demo22').innerHTML = array1.concat(array2, array3);
    }
    {
        const fruits = ["Pineapple", "Apple", "Mango", "Watermellon"];
        fruits.splice(2,0, "Lemon", "Grapes");
        document.getElementById('demo23').innerHTML = fruits;

    }
    {
        const points = [40, 100, 1, 5, 25, 10];
        points.sort(function(a,b){return a-b});
        document.getElementById('demo24').innerHTML = points;
    }
    {
        const points = [40, 100, 1, 5, 25, 10];
        document.getElementById('demo25').innerHTML = myArrayMin(points);
        function myArrayMin(arr){
            let len = points.length;
            let min = Infinity;
            while(len--){
                if (arr[len] < min){
                    min = arr[len];
                }
            }
            return min;
        }
    }
    {
        const points = [40, 100, 1, 5, 25, 10];
        txt = "";
        points.forEach(myeachfunction);
        document.getElementById('demo26').innerHTML = txt;
        function myeachfunction(value){
            txt += value + "<br>";
        }
        
    }
    {
        const numbers1 = [45, 4, 9, 16, 25];
        const numbers2 = numbers1.map(myFunction);
        document.getElementById('demo27').innerHTML = numbers2;
        function myFunction(value){
            return value*2;
        }
    }
    {
        const numbers1 = [45, 4, 9, 16, 25];
        const numbers2 = numbers1.filter(myFunction);
        document.getElementById('demo28').innerHTML = numbers2;
        function myFunction(value){
            return value > 18;
        }
    }

    {
        const numbers1 = [45, 4, 9, 16, 25];
        const sum = numbers1.reduce(myFunction);
        document.getElementById('demo29').innerHTML = "The sum is " + sum;
        function myFunction(total, value){
            return total + value;
        }
    }
    /*https://www.w3schools.com/js/js_array_iteration.asp  --> reference for all the methods*/
    
    {
    const fruits = ["Banana", "Orange", "Apple", "Mango"];
    const keys = fruits.keys();

    let text = "";
    for (let x of keys) {
    text += x + "<br>";
    }

    document.getElementById("demo30").innerHTML = text;
    }
    {
        const fruits = ["Banana", "Orange", "Apple", "Mango"];
        const f = fruits.entries();
        
        for (let x of f) {
          document.getElementById("demo31").innerHTML += x + "<br>";
        }
    }
    {
        const date = new Date();
        document.getElementById('demo32').innerHTML = date;

    }
    {
        const date = new Date();
        
        document.getElementById('demo33').innerHTML = date.toDateString()

    }
    {
        const d = new Date();
        d.setFullYear(2020, 11, 3);
        document.getElementById("demo34").innerHTML = d;
    }
    {
        document.getElementById("demo35").innerHTML = Math.random();
    }
    {
        document.getElementById("demo36").innerHTML = Boolean(10>9);
    }

}

