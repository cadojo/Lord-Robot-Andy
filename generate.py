#!/usr/bin/python3

# Let's use textgenrnn to train a natural language
# model with Lord Andy works!

# But first, imports
from textgenrnn import textgenrnn

# We need to instantiate a `textgenrnn` object
textgen = textgenrnn()

# Let's train the model with the script for Love Never Dies
textgen.reset()
textgen.train_from_largetext_file('scripts/love-never-dies.txt', 
                        new_model=True,
                        word_level=True,
                        num_epochs=1)

# Here goes nothing!
textgen.generate_to_file('generated/love-never-ever-dies.md', temperature=0.75)