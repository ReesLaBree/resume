#!/usr/bin/python3

import sys
import operator
from collections import Counter

#taken from Wikipedia
letter_freqs = {
    'A': 0.08167,
    'B': 0.01492,
    'C': 0.02782,
    'D': 0.04253,
    'E': 0.12702,
    'F': 0.02228,
    'G': 0.02015,
    'H': 0.06094,
    'I': 0.06966,
    'J': 0.00153,
    'K': 0.00772,
    'L': 0.04025,
    'M': 0.02406,
    'N': 0.06749,
    'O': 0.07507,
    'P': 0.01929,
    'Q': 0.00095,
    'R': 0.05987,
    'S': 0.06327,
    'T': 0.09056,
    'U': 0.02758,
    'V': 0.00978,
    'W': 0.02361,
    'X': 0.00150,
    'Y': 0.01974,
    'Z': 0.00074
}

alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

"""
def chi_squared(s):
    freq = [0]*26
    total = float(len(s))
    for l in s:
        freq[ord(l) - ord('A')] += 1
    freq = [f / total for f in freq]
    return sum((f - E)**2 / E for f, E in zip(freq, letter_freqs.values()))
"""

def chi_squared(s):
    sums = 0
    string_dict = {}

#    print("-----------")
#    print("original string: ", s)


    # find frequency of letters in string
    for char in s:
        if char in string_dict:
            string_dict[char] += 1
        else:
            string_dict[char] = 1

#    print("dictionary counts: ", string_dict)

    s_len = len(s)

    for letter in alphabet:
        if letter not in string_dict:
            string_dict[letter] = 0
        sums += (pow((string_dict[letter] / s_len) - letter_freqs[letter], 2)/float(letter_freqs[letter])) 
#        print("combination: ", letter, " , ", letter_freqs[letter], " , ", string_dict[letter])
#        print(s)
#        print(sums)

#   print(sums)
    return sums


def pop_var(s):
    """Calculate the population variance of letter frequencies in given string."""
    print(s)
    freqs = Counter(s)
    mean = sum(float(v)/len(s) for v in freqs.values())/len(freqs)  
    x = sum((float(freqs[c])/len(s)-mean)**2 for c in freqs)/len(freqs)
    print(x)
    return(x)

def calc_likely_length(ciph_text, seq_len, min_length, max_length):
    # make a dictionary of all possible sequences of length seq_len
    # dictionary should record the distance from the start to each occurrence
    sequences = {}
    for i, j in enumerate(ciph_text):
        sequence = ciph_text[i:i+seq_len]
        if sequence in sequences:
            sequences[sequence].append(i)
        else:
            sequences[sequence] = [i]

#    print(sequences)

    # make a dictionary of key lengths
    # if modulo(key length) between each occurrence = 0, then iterate the value of key=length
    keylen = {}
    for i in range(2,14):
        for seq in sequences:
            if len(sequences[seq]) > 1:
                elements = sequences[seq]
                for el_num, el in enumerate(elements):
                    for el_num_2, el_2 in enumerate(elements):
                        if el_num_2 > el_num:
                            #print(el_num, el_num_2)
                            #print((el_2 - el) % i, i)
                            d = (el_2 - el) % i
                            if d == 0 and i in keylen:
                                keylen[i] += 1
                            elif d == 0:
                                keylen[i] = 1             

    # return the key with the highest value
    # this is the likely key length
    return max(keylen.items(), key = operator.itemgetter(1))[0]

def calc_key(key_len, cipher_text):
    # break cipher text into (k) lists such that every multiple of k belongs to a list
    key = ''
    for i in range(key_len):
        best_var = -1
        best_char = ''

        # i = index of the csr in lst
        # use i to index best_var and best_char
        csr = "".join(cipher[i::key_len])

        for num in range(26): 
            check_offset = ''
            for char in csr:
                char_num = alphabet.find(char)
                # j = index of character in the csr string
                # char = character in csr string
                # offset char_num
                char_num -= num
                # if char_num exceeds 25, subtract 26 from it
                if char_num < 0:
                    char_num += 26
                # new_char should be equal to alphabet indexed at char_num
                check_offset += alphabet[char_num]
            # now we have a string check_offset that represents the caesar cipher with num offset
            # run the test!          
            test_chi_squared = chi_squared(check_offset)

            if test_chi_squared < best_var or best_var == -1:
                best_var = test_chi_squared
                best_char = alphabet[num]

        key += best_char

    return key


def main(cipher):
    min_length = 2
    max_length = 13
    key_length = calc_likely_length(cipher, 3, min_length, max_length)
    # print(key_length)
    key = calc_key(key_length, cipher)
    print(key)

if __name__ == "__main__":
    # Read ciphertext from stdin
    # Ignore line breaks and spaces, convert to all upper case
    
    cipher = sys.stdin.read().replace("\n", "").replace(" ", "").upper()

    #################################################################
    # Your code to determine the key and decrypt the ciphertext here
    main(cipher)






