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
        let len = fruits.length;
        let txt = "<ul>" 
        for (i=0; i < len; i++){
            txt += "<li>" + fruits[i] + "</li>";
        }
        txt += "<ul>"
        document.getElementById('demo18').innerHTML = txt;
    }
}