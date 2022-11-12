'''class Dog:
    def __init__(self, name, age):
        self.name = name
        self.age = age
        #print(self.age)
        
    def add_one(self, x):
        return x  + 1

    def  bark(self):
        print("bark")

    def get_name(self):
        return self.name

    def get_age(self):
        return self.age

    def set_age(self, age):
        self.age = age



d = Dog("Jake", 18)
print(d.get_name())
d.set_age(20)
print(d.get_age())
'''




class Student:
    def __init__(self, name, age, grade):
        self.name =  name
        self.age  = age
        self.grade = grade # 0-100
    
    def get_grade(self):
        return self.grade

class Course:
    def __init__(self, name, max_students):
        self.name = name
        self.max_students =  max_students
        self.students = []

    def add_student(self, student):
        if len(self.students) < self.max_students:
            self.students.append(student)
            return True
        return False

    def get_average_grade(self):
        value = 0
        for student in self.students:
            value += student.get_grade()

        return value / len(self.students)

s1 = Student("Jake", 19, 93)
s2 = Student('Kite', 20, 85)
s3 = Student('Gina', 18, 71)

'''course = Course('Science', 2)
course.add_student(s1)
print(course.add_student(s2))
print(course.add_student(s3))

print(course.get_average_grade())

'''

######### Inheritance #############

class Pet: # generalization
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def show(self):
        print(f"I am {self.name} and I am {self.age} years old")

    def speak(self):
        print("I don't know what to say")

class Cat(Pet): # specific
    def __init__(self, name, age, color):
        super().__init__(name,age)
        self.color = color
    def speak(self):
        print("Meow")
    def show(self):
        print(f"I am {self.name} and I am {self.age} years old and I am {self.color}")
    
class Dog(Pet): # specific
    def speak(self):
        print('Bark')

class Fish(Pet):
    pass

'''p = Pet('jack', 19)
p.speak()
c = Cat('Tim', 32, 'white')
c.speak()
c.show()
d = Dog('bolt', 12)
d.speak()
f = Fish('Jericho', 10)
f.speak()'''


'''class Person:
    def  __init__(self, name,  age, id, birthdate):
        self.name = name
        self.age = age
        self.id = id
        self.birthdate  = birthdate


class Manager(Person):
    def __init__(self, name,  age, id, birthdate, lead):
        super().__init__(name, age, id, birthdate)
        self.lead = lead
    def show(self):
        print(f"I am {self.name},  the manager and I  am {self.age} years old.  My birthdate is on {self.birthdate}")

class Employee(Person):
    def __init__(self, name,  age, id, birthdate, follow):
        super().__init__(name, age, id, birthdate)
        self.follow = follow
        print(f"I am {self.name} an employee and I  am {self.age} years old.  My birthdate is on {self.birthdate}  and  I follow {self.lead}")


m  = Manager('Tom', 23, 485920, '10 Sep', 'Jay')
m.show()
'''
##### Class  methods ########

class Person: 
    number_of_people  = 0  # class attribute

    def __init__(self,name):
        self.name = name
        Person.add_people()

    @classmethod # decorator to denote this specific method is a class method
    def  number_of_people_(cls): # this don't have access on any instance 
        return cls.number_of_people

    @classmethod
    def add_people(cls):
        cls.number_of_people += 1
        
'''  
p1 = Person('Tom')
#print(p1.number_of_people)
p2 = Person('Jamie')
#print(Person.number_of_people)
print(Person.number_of_people_())
'''

########### static methods ###########
#def add4(x): # global function

   # return x+ 4
class Math:
    @staticmethod  # they do not have access to an instance. They are not changing, staying the same 
    def add5(x): # no need to putr self or cls because it's not going to access anything
        return x + 5

    @staticmethod
    def add10(x): # no need to putr self or cls because it's not going to access anything
        return x + 10

    @staticmethod
    def pr():
        print("Hi")

print(Math.add5(3))
print(Math.add10(3))
Math.pr()


list = [1,2,3]
list.append((4))
print(list)



from collections import defaultdict

class Solution:
       def mySqrt(self, x: int) -> int:
        #return int(math.sqrt(x))
        # Binary search approach
        l = 0
        r = x
        if x == 1 or x == 0:
                return x  
        while l < r:
            m = l+r//2
            if m*m > x:
                r = m
            if m*m < x:
                l = m
            if m*m == x:
                return m
            
class Codec:
    def encode(self, strs):
        """Encodes a list of strings to a single string.
        """
        encode = ""
        for e in strs:
            encode += str(len(e)) + "#" + e
        return encode

    def decode(self, s: str):
        """Decodes a single string to a list of strings.
        """
        decode, i = [], 0
        while i < len(s):
            j = i
            while s[j] != "#":
                j += 1
            length = int(s[i:j])
            decode.append(s[j+1:j+1 + length])
            i = j+ 1+length
        return decode
co = Codec()
print(co.decode("5#Hello5#World"))
        
        
        

test  = Solution()
print(test.mySqrt(8))
