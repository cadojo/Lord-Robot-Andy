#!/usr/bin/python3

# Let's use textgenrnn to train a natural language
# model with Lord Andy works!

# But first, imports
from textgenrnn import textgenrnn

# We need to instantiate a `textgenrnn` object
textgen = textgenrnn()

# Let's train the model with the script for Love Never Dies
textgen.train_from_file('scripts/love-never-dies.txt')

# Here goes nothing!
textgen.generate_to_file('generated/love-never-ever-dies.txt')