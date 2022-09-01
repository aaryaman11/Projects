# ------python built in data structures-------------
'''
--> List
General purpose  
most widely used data structure 
grow and shrink in size as needed
sequence  type
sortable

'''
x = list()
y = ['a', 23, 'b', 44]
del(y[2])
tuple = (20, 40)
z = list(tuple)
print(x, y, z)

a = [m**3 for m in range(9) if m > 5]
print(a)

p = [5, 3, 8, 7, 9]
p.insert(4, 6)  # the first digit is the position and the other one is the digit we insert (4--> position in the list, 6--> digit)
print(p)

# pop --> pops the last item off the list and return them
p.pop()
print(p)
# print(p.pop())

# reverse theorder of the list
p.reverse()
print(p)

# there are 2 sorts
# sorted(x) returns a new sorted list without changing the original
# x.sort() will sort the items of x or the original list in sorted order and returns
print(sorted(p))
p.sort(reverse=True)  # using reverse parameter for descending list
print(p)

'''
--> Tuples
immutable (can't add/change)
useful for fixed data
faster than lists
sequence type

'''
t = ()
t = (1, 2, 3)
t = 1, 2, 3
t = 1,  # , tells python  it's a tuple
print(t, type(t))

g = (2,3,4)
# del(g[1]) -->TypeError: 'tuple' object doesn't support item deletion
h = ([1,3], 6)
del(h[0][1])
h += (4,) # concatening will work on tuple
print(h)

'''
--> Sets
Store non duplicate items
very fast access vs list
Math Set ops (union, intersect)
Sets  are  Unordered
you cannot sort a set
'''
# you can find item in a set instantly compared to list in which you have to go through every iteration 

k = {2,4,2,4}
print(k)

l = set()

list2 = [3,7,8,9]
z = set(list2)
print(z)
# add and remove work for the set
c = {1,3,7,9}
c.add(5)
print(c)
c.remove(3)
print(c)
print(3 in c)
# for pop it would random in the set
print(c.pop(), c)
# to delete all the items from the set
print(c.clear())

# set mathematical operations
s1 = {1,2,3}
s2 = {3,5,6}
print(s1 & s2)
print(s1 | s2)
print(s1 ^ s2)
print(s1 - s2)
print(s1 <= s2)
print(s1 >= s2)

'''
--> Dictionaries 
key/Balue pairs
Assosciate array, like Java Hashmap
Dictionaries are unordered
They can be converted into a list and then sorted 

'''
# Three different way to make dict
print()
print("Dictionary examples")
n = {"a": 2, 'b': 3, 'c':4}
print(n)
m = dict([('a',3), ('b', 4), ('c',5)]) # a  tuple then a list and then the dict constructor
print(m)
j = dict(a=3, b=4, c=5)
print(j)
n['d'] = 6 # adding  or updating the dict
del(n['b'])  # deleting in dict
print(n)
j.clear()  # clear the dict
print(j)
del(m) # delete the whole dict

# to  access key  and values separately 

print(n.keys())
print(n.values())
print(n.items()) # key/value pairs
print('e'  in  n) # checking the  key in the dict not values
print(7 in n.values())  # checking the  value in the dict 

# iterating the  dict 2 ways
for  key in n:
    print(key, n[key])

print()

for k, v in n.items():
    print(k, v)

#------ python built in data structures end--------------


'''
list comprehensions
'''
import random
under_10 = [x for x in range(10)]
print(f"under_10: {under_10}")

squares = [x**3 for x in under_10]
print(squares)

text = 'I want 2 go 2 seattle'
num = [x for x in text if x.isnumeric()]
print(f'nums: {num}')

names = ['cosmos', 'Pedro', 'Anu', 'Ray']
idx = [k for k, v in enumerate(names) if v == 'Anu']
print(idx)

letters = [x for x in 'ABCDEF']
random.shuffle(letters)
lets = [a for a in letters if a != 'B']
print(letters, lets)

'''
--> Stacks
LIFO--> last in First out
can use push to push an item on the  stack and pop an item off the stack
Peek --> get item on top of stack, without removing it
clear --> all  items from the stack 
can use append to  push onto the stack

Stack using python list

'''
my_stack =  list()
my_stack.append(3)
my_stack.append(9)
my_stack.append(12)
my_stack.append(25)
print(my_stack)
print(my_stack.pop())
print(my_stack.pop())

print()

#  ---------Stacks using list with a wrapper class-----------

# to implemet the stack 
# need the push and pop feature 

class Stack():
    def __init__(self):
        self.stack = list()
    def push(self, item):
        self.stack.append(item)
    def pop(self):
        if len(self.stack) > 0:
            return self.stack.pop()
        else:
            return None
        #self.stack.remove(item)
    def peek(self):
        if len(self.stack) > 0:
            return self.stack[len(self.stack)-1]
        else:
            return None
    def __str__(self): # string representation of the stack
        return str(self.stack)

my_stack1 = Stack()
my_stack1.push(45)
my_stack1.push(35)
my_stack1.push(75)
my_stack1.pop()
print(my_stack1.peek()) 

print()
    
# python list is a verstalie data structure we make stack from it

# -----------------------------------------------------------

'''
--> Queues
FIFO --> First in First Out
Enqueue --> add an item at the end of the line
Dequeue --> remove an item from the front of the line

Queue using python Deque
Deque is a double ended queue, but we can use it for our queue --> it allows add and remove from both ends of the queue
we use append() to enqueue an item, and popleft() to dequeue an item
check python docs for Deque

'''
from collections import deque
my_queue = deque()
my_queue.append(6)
my_queue.append(20)
print(my_queue)
print(my_queue.popleft())

#  ---------Queue using list with a wrapper class-----------

class Queue():
    def __init__(self):
        self.queue = list()
    def dequeue(self):
        if len(self.queue) > 0:
            return self.queue.pop(-len(self.queue))
        else: 
            return None
    def enqueue(self, item):
        self.queue.append(item)
    def get_size(self):
        return len(self.queue)
    def __str__(self):
        return str(self.queue)

my_queue1 = Queue()
my_queue1.enqueue(4)
my_queue1.enqueue(8)
my_queue1.enqueue(34)
my_queue1.enqueue(59)
print(my_queue1)
print(my_queue1.dequeue())
print(my_queue1.get_size())

# -------------------------------------------------

'''
--> MaxHeap
Complete Binary tree
Every node <= it's parent 
top number in the heap is the highest  number and it could be instantly removed and used
for MaxHeap we use our element at index no. 1
- MaxHeap is fast
- Insert is in O(logn)
- Get Max in O(1)
- Remove MAx in O(logn) 
'''
# Easy to implement using a List
# MaxHeap operations
# Push(inset), Pop(get max), Peek(remove max)
# - Push --> [Add value to the end of array
# --> Float is up to its proper postion v]
# - Pop --> [Move max to the end of the array 
# delete it
# bubble dow the item at index 1 to its proper position
# return max]


#  ---------MaxHeap using list with a wrapper class-----------

# MaxHeap bubbles the highest value to the top, so it can removed instantly 
# public function: push, pop, peek
# private functions: swap, _floatup, _bubbledown, _str
# https://www.youtube.com/watch?v=kQDxmjfkIKY for refernce 

class MaxHeap():
    def __init__(self, items=[]):
        self.heap = [0]
        for item in items:
            self.heap.append(item)
            self.__floatUp(len(self.heap)-1) # floating up to it's proper position

    def push(self, data):
        self.heap.append(data)
        self.__floatUp(len(self.heap)-1)

    def peek(self):
        if self.heap[1]:
            return self.heap[1]
        else:
            return False

    def pop(self):
        if len(self.heap) > 2:
            self.__swap(1, len(self.heap) -1)
            max = self.heap.pop()
            self.__bubbleDown(1)
        elif len(self.heap) == 2:
            max = self.heap.pop()
        else:
            max = False
        return max

    def __swap(self, i, j):
        self.heap[i], self.heap[j] = self.heap[j], self.heap[i]

    def __floatUp(self, index):
        parent = index//2 # // --> floor division
        if index <= 1:
            return 
        elif self.heap[index] > self.heap[parent]:
            self.__swap(index, parent)
            self.__floatUp(parent) # reculsive 

    def __bubbleDown(self, index):
        left = index * 2
        right = index * 2 + 1
        largest = index
        if len(self.heap) > left and self.heap[largest] < self.heap[left]:
            largest = left
        if len(self.heap) > right and self.heap[largest] < self.heap[right]:
            largest = right
        if largest != index:
            self.__swap(index, largest)
            self.__bubbleDown(largest) # reculsive 
    
    def __str__(self):
        return str(self.heap)

print()
print("Max Heap Example")
hp = MaxHeap([85, 5,4])
hp.push(10)
print(hp)
print(hp.pop())
print(hp.peek())

# -----------------------------------------------------------

# with big data list are not useful
'''
--> Linked List
Every node has 2 parts. data and a pointer to the next node
each node has it's own piece data and also pointing to the next node
The front is Root node 
Attributes:
- root--> pointer to the beginning of the list
- size--> number of nodes in list
Operations:
- find(data)
- add(data)
- remove(data)
- print_list()

The new node is inserted in front of the root node and becomes the new root node
for reference --> https://www.youtube.com/watch?v=kQDxmjfkIKY


'''

# -------------------Node class-----------------------------------

# we will use the same node class for doubly linked list and circular linked list
# we don't need previous_node for a standard linked list
class Node:

    def __init__(self, d, n = None, p=None):
        self.data = d
        self.next_node = n
        self.prev_node = p

    def __str__(self):
        return ('(' + str(self.data) + ')')
    

# ------------------------------------------------------------------

# --------------------LinkedList-------------------------------------

class LinkedList:

    def __init__(self, r = None):
        self.root = r # keep track of the root node
        self.size = 0 #  keep track of size when adding or removing the node

    def add(self, d):
        new_node = Node(d, self.root) # the current root node will become the second node after adding
        self.root = new_node
        self.size += 1

    def find(self, d):
        this_node = self.root # starting at the root node
        while this_node is not None:
            if this_node.data == d:
                return d
            else:
                this_node = this_node.next_node # bump us into the next node 

        return None

    def remove(self, d):
        this_node =  self.root
        prev_node = None # keep track of previous node when we remove
        while this_node  is not None:
            if this_node.data == d:
                if prev_node is not None: # data is not in the root but in some other node
                    prev_node.next_node = this_node.next_node

                else: # if data is in the root
                    self.root = this_node.next_node
                self.size -= 1
                return True # data removed
            else:
                prev_node  = this_node # bumping both iterators
                this_node = this_node.next_node # bumping both iterators
        return False # data not found

    def print_list(self):
        this_node = self.root
        while this_node is not None:
            print(this_node, end='->')
            this_node = this_node.next_node
        print('None')

print()
print('LinkedList example')
myList = LinkedList()
myList.add(5)
myList.add(9)
myList.add(13)
myList.print_list()


print("size="+str(myList.size))
myList.remove(9)
print("size="+str(myList.size))
print(myList.find(5))
print(myList.root)

# ------------------------------------------------------------------

# -----------------------Circular LinkedList----------------------------

'''
Circular LinkedList

In this at the end the pointer is not pointing at None but towards the first/root node

The add operation works a liitle different in this
the new node is not inserted as the root node but as the second node or after root node
Advantages --> ideal for modeling continous looping objects, such as a Monopoly board or a race track
'''

# similar to regular Linkedlist

class CircularLinkedList:
    def __init__(self, r=None):
        self.root = r
        self.size = 0
    
    def add(self, d):
        if self.size == 0:
            self.root = Node(d)
            self.root.next_node = self.root
        else:
            new_node = Node(d, self.root.next_node)
            self.root.next_node = new_node
        self.size += 1

    def find(self, d):
        this_node = self.root
        while True:
            if this_node.data == d:
                return d
            elif this_node.next_node == self.root:
                return False
            this_node = this_node.next_node

    def remove(self, d):
        this_node = self.root
        prev_node = None
        while True:
            if this_node.data == d: # found the node
                if prev_node is not None:
                    prev_node.next_node = this_node.next_node
                else:
                    while this_node.next_node != self.root:
                        this_node = this_node.next_node
                    this_node.next_node = self.root.next_node
                    self.root = self.root.next_node
                self.size -= 1
                return True # data is removed
            elif this_node.next_node == self.root:
                return False
            prev_node = this_node # both moved ahead 1 node
            this_node = this_node.next_node # both moved ahead 1 node

    def print_list(self):
        if self.root is None:
            return
        this_node = self.root
        print(this_node, end='-->')
        while this_node.next_node != self.root:
            this_node = this_node.next_node
            print(this_node, end='-->')
        print()


print() # new line for separation

cll =  CircularLinkedList()
for  i in [5,7,3,8,9]:
    cll.add(i)
print("size: " + str(cll.size))
print(cll.find(8))
print(cll.find(12))

my_node = cll.root
print(my_node, end='-->')
for i in range(8):
    my_node = my_node.next_node
    print(my_node, end='-->')
print()

print()

cll.print_list()
cll.remove(8)
print(cll.remove(15))
print("size: " + str(cll.size))
cll.remove(5)
cll.print_list()

# ----------------------------------------------------------------

# -----------------------Doubly LinkedList----------------------------

'''
Doubly linkedlist-->
Every Node has 3 parts: data and pointers to previous and next nodes

Advantages over regular LinkedList:
- can iterate the list in either direction
- can delete a node without iterating through the list (if given a pointer to the node) 

'''

# doubly linkedlist uses a extra node attribute called prev node and it also have a extra list attribute called last so we can access the last element in the list

class DoublyLinkedList:
    def __init__(self, r = None):
        self.root = r
        self.last = r
        self.size = 0

    def add(self, d):
        if self.size == 0:
            self.root = Node(d)
            self.last = self.root
        else:
            new_node = Node(d, self.root)
            self.root.prev_node = new_node
            self.root = new_node
        self.size += 1

    def find(self, d):
        this_node = self.root
        while this_node is not None:
            if this_node.data == d:
                return d
            elif this_node.next_node == None:
                return False
            else:
                this_node = this_node.next_node

    def  remove(self, d):
        this_node = self.root
        while this_node is not None:
            if this_node.data ==d:
                if this_node.prev_node is not None:
                    if this_node.next_node is not None: # delete from the middle
                        this_node.prev_node.next_node = this_node.next_node
                        this_node.next_node.prev_node = this_node.prev_node
                    else: # delete last node
                        this_node.prev_node.next_node = None 
                        self.last = this_node.prev_node
                else:
                    self.root = this_node.next_node
                    this_node.next_node.preb_node = self.root
                self.size -= 1
                return True # data removed
            else:
                this_node = this_node.next_node
        return False

    def print_list(self):
        if self.root is None:
            return
        this_node = self.root
        print(this_node, end='-->')
        while this_node.next_node is not None:
            this_node = this_node.next_node
            print(this_node, end='-->')
        print()

print()

dll = DoublyLinkedList()
for i in [5,9,3,8,9]:
    dll.add(i)

print("size: " + str(dll.size))
dll.print_list()
dll.remove(8)
print("size" + str(dll.size))

print(dll.remove(15))
print(dll.find(15))
dll.add(21)
dll.add(22)
dll.remove(5)
dll.print_list()
print(dll.last.prev_node)

# ----------------------------------------------------------------


# -----------------------Trees------------------------------------

'''
Tree-->
- Each part of the tree is called a node
- Each connection between a node is called an edge
- top of the tree we have root node
- parent node and child node
- parent can have 1 or 2 children
- the bottom of the tree which don't have any children are called leaf nodes
- Not all trees are binary trees, but in a binaryu tree each node can have up to 2 child nodes, a left or right child node
- 2 Standard requiremnet for binary search tree --> 
-** In a binary search tree each node is grater than every node in its left subtree
-** each node is less than every node in right sub tree
Stand operations:
Insert --> we always start at the root, always insert at the leaf. we start at the top to locate the right position
find --> we always start at the root
delete --> 3 possibilities--> leaf node(just delete the leaf node), 1 child(promote the child to the target node's position) , 2 children (find the next higher node and then the left most node in the right subtree)
get_size --> Returns number of nodes. Works reculsively --> size = 1 +size(left subtree) + (right subtree)
Traversals --> enables us to walk through the tree node by node 
 - Preorder traversal, level traversal,  inorder traversal and postorder traversal 
Preorder Traversal --> visit root before visting the root's subtree
Inorder traversal --> Visting root between visting the root's subtree. goes to the ;left most subtree and then make it's way up. Gives value in a sorted order
future reference --> https://www.youtube.com/watch?v=kQDxmjfkIKY
'''
## Adavntages of Binary search tree:
# - because trees use recursions for most operations they are fairy easy to operate 
# Speed of Binary tree:
# insert, delete, find in O(h) = O(logn) (h --> is height of the tree)
# in a balanced BST with 10,000,000 nodes it would take 30 comparisons 

class Tree:
    def __init__(self, data, left= None, right= None):
        self.data = data
        self.left = left
        self.right = right

    def insert(self, data):
        if self.data == data:
            return False # duplicate value
        elif self.data > data:
            if self.left is not None:
                return self.left.insert(data)
            else:
                self.left = Tree(data) # left subtree of it's parent node
                return True # becasue we added that data
        else:
            if self.right is not None:
                return self.right.insert(data)
            else:
                self.right = Tree(data)
                return True

    def find(self, data):
        if self.data == data:
            return data
        elif self.data > data:
            if self.left is None:
                return False
            else:
                return self.left.find(data)
        elif self.data < data:
            if self.right is None:
                return False
            else:
                return self.right.find(data)

    def get_size(self):
        if self.left is not None and self.right is not None:
            return 1+ self.left.get_size() + self.right.get_size()
        elif self.left:
            return 1 + self.left.get_size()
        elif self.right:
            return 1 + self.right.get_size()
        else:
            return 1

    def preorder(self):
        if self is not None:
            print(self.data, end=' ')
            if self.left is not None:
                self.left.preorder()
            if self.right:
                self.right.preorder()

    def inorder(self):
        if self is not None:
            if self.left is not None:
                self.left.inorder()
            print(self.data, end=' ')
            if self.right:
                self.right.inorder()

print()

tree = Tree(7)
tree.insert(9)
for i in [15, 10, 2, 12, 3, 1, 13, 6, 11, 4, 14, 9]:
    tree.insert(i)
for i in range(16):
    print(tree.find(i), end=' ')
print('\n', tree.get_size())

tree.preorder()
print()
tree.inorder()
print()

#----------------------------------------------------------------


#----------------------------Undirected Graphs-----------------------------------

'''
Undirected Graphs --> for example relationships are two way (bi directional)
for modeling real word objects
Adjacency List--> List of neighbors stored in each vertex
Adjacency Matrix--> matrix of neighbors stored centrally in graph object (stores in a 2d array all the connecton between vertices and the graph object) (symmetrical along the diagonal)
with weighted edges it is much easier to implement with adjacency matrix 
Dense graph-> graph where |E| = |V|^2
'''

#----------------------------Directed Graphs-----------------------------------

'''
Directed Graphs --> for example modeling flight (one way relationship)
2 most common ways to implementy graph 
Adjacency List--> you just put the outbound edges from each vertex
Adjacency Matrix--> it is not going to be symmetrical accross the diagonal anymore
Sparse graph --> graph where |E| = |V|

Adjacency list -->
- pro: faster and uses less space for sparse graph
- con: slower for dense graph

Adjacency Matrix-->
- pro: faster for dense graph
- pro: simpler for weighted edges
- con: uses more space --> as the number of vertices grows the amount of space required for the adjacency matrix grows by a factor of E^2
- 
https://www.youtube.com/watch?v=kQDxmjfkIKY
'''
# Graph implementation using Adjacency List
class Vertex:
    def __init__(self, n):
        self.name = n # name of the vertex
        self.neighbors = set() # neigbors of the vertex, sets don't store duplicates

    def add_neighbors(self, v):
        self.neighbors.add(v)

class Graph:
    vertices = {} # using dictionary for vertex object and vertex name

    def add_vertex(self, vertex):
        if isinstance(vertex, Vertex) and vertex.name not in self.vertices: # checking if it is vertex object using isinstance
            self.vertices[vertex.name] = vertex
            return True
        else:
            return False

    def add_edge(self, u, v):
        if u in self.vertices and v in self.vertices:
            self.vertices[u].add_neighbors(v)
            self.vertices[v].add_neighbors(u)
            return True
        else:
            return False

    def print_graph(self):
        for key in sorted(list(self.vertices.keys())):
            print(key, sorted(list(self.vertices[key].neighbors)))

print()

gr = Graph()
a = Vertex('A')
gr.add_vertex(a)
gr.add_vertex(Vertex('B'))
for i in range(ord('A'), ord('K')): # ord converting into int factor and using chr to convert back to letter
    gr.add_vertex(Vertex(chr(i)))

edges = ['AB', 'AE', 'BF', 'CE', 'DE', 'DH', 'EH', 'FG', 'FI', 'FJ', 'GJ']
for edge in edges:
    gr.add_edge(edge[0], edge[1])

gr.print_graph()

print()

# Graph implementation using Adjacency Matrix

class Vertex:
    def __init__(self, n):
        self.name = n

# graph object have 3 attributes
# vertices - a dictionary with vertex_name:vertex_object
# edges - a 2-dimensional list(ie. a matrix) of edges for an unweighted graph it 
# will contain 0 for no edge and 1 for edge
# edge_indices - a dictionary with vertex_name:list_index(eg A:0) to access edges
# add_vertex updates all three of these attributes
# add_edge onlly needs to update the edges matrix
class Graph:
    vertices = {}
    edges = []
    edge_indices = {}

    def add_vertex(self, vertex):
        if isinstance(vertex, Vertex) and vertex.name not in self.vertices:
            self.vertices[vertex.name] = vertex
            # loop appends a column of zeros to the edges matrix or right most side of the matrix
            for row in self.edges:
                row.append(0)
            # append a row of zeros to the bottom of the edges matrix
            self.edges.append([0]*(len(self.edges)+1))
            self.edge_indices[vertex.name] = len(self.edge_indices)
            return True
        else:
            return False 

    def add_edge(self, u, v, weight = 1):
        if u in self.vertices and v in self.vertices:
            self.edges[self.edge_indices[u]][self.edge_indices[v]] = weight
            self.edges[self.edge_indices[v]][self.edge_indices[u]] = weight
            return True
        else:
            return False

    def print_graph(self):
        for v, i in sorted(self.edge_indices.items()):
            print(v + '', end=' ')
            for j in range(len(self.edges)):
                print(self.edges[i][j], end=' ')
            print(' ')

gr = Graph()
a = Vertex('A')
gr.add_vertex(a)
gr.add_vertex(Vertex('B'))
for i in range(ord('A'), ord('K')): # ord converting into int factor and using chr to convert back to letter
    gr.add_vertex(Vertex(chr(i)))

edges = ['AB', 'AE', 'BF', 'CE', 'DE', 'DH', 'EH', 'FG', 'FI', 'FJ', 'GJ']
for edge in edges:
    gr.add_edge(edge[0], edge[1])

gr.print_graph()


class Solution:
    def twoSum(self, nums: int, target: int):
        # check the sum of number which is equla to target 
        # output should be in another list too 
        # output would be the index of the numbers 
        '''index = []
        for i in range(len(nums)):
            for j in range(1+i, len(nums)):
                if nums[i] + nums[j] == target:
                    index.append(i)
                    index.append(j)
        return index'''
        dict_check = {}
        for i, v in enumerate(nums):
            diff = target - v
            if diff in dict_check:
                return [dict_check[diff], i]
            else:
                 dict_check[v] = i



ss = Solution()
print(ss.twoSum([3,2,4], 5))
