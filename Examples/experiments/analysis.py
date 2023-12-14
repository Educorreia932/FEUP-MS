import re

def calculate_time_to_find_path(file_content):
    number_of_passengers = len(file_content)/3 -1
    print('The total amout of passengers is: ', number_of_passengers)

    passenger_info_list = []
    for i in range(0, len(file_content), 3):
        passenger_info_set = file_content[i:i+3]
        passenger_info_list.append(passenger_info_set)

    

# Read the file
file_path = '/Users/user/Desktop/UNI/MS/Projeto/Examples/experiments/2023_12_08_22_34_01.txt'
with open(file_path, 'r') as file:
    file_content = file.readlines()

# Call the function to calculate time to find the right path
calculate_time_to_find_path(file_content)
