# need to ask the user if they want to list their passwords or store them
# need to store the password in a list
# encrypting them
# creating a master password to access the file

from cryptography.fernet import Fernet


user_pwd = input("Enter the master password: ")

# using a key + master password(user_pwd) + targeted input to encrypt to result in random output or encrypted password
# using a key + master password(user_pwd) + random output = actual input or password user put before

# function to make the key

'''
def write_key():
    key = Fernet.generate_key()
    with open("key.key", "wb") as key_file:
        key_file.write(key)'''

# function to load the key


def load_key():
    file = open("key.key", "rb")
    key = file.read()
    file.close()
    return key


load_key()


def add():
    account = input("Account name: ")
    password = input("Enter the password: ")

# by using with it  would allow to open and close the file automatically
# there are 3 modes --> 'a' --> append mode, 'w' --> it would write the whole or destroy the file completely if the file already exists, 'r' --> this is just read mode
# reference --> https://www.programiz.com/python-programming/file-operation
    with open("passowrds.txt", "a") as f:
        f.write(account + "|" + password + "\n")


def view():
    with open("passowrds.txt", "r") as f:
        for line in f.readlines():
            # refernce --> https://itsmycode.com/python-trim-string-rstrip-lstrip-strip/
            data = line.rstrip()
            # refernce --> https://www.w3schools.com/python/ref_string_split.asp
            user, passwo = data.split("|")
            print("User: " + user, "| password: " + passwo)


while True:
    option = input(
        "Do you want add a new password or view the existing ones? (add, view), press q to quit: ").lower()
    if option == "q":
        break
    if option == "add":
        add()
    elif option == "view":
        view()
    else:
        print("Invalid command.")
        continue
