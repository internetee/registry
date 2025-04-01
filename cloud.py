#!/usr/bin/env python
"""
Masked wordcloud
================

Using a mask you can generate wordclouds in arbitrary shapes.
"""

from os import path
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
import os

from wordcloud import WordCloud, STOPWORDS

# get data directory (using getcwd() is needed to support running example in generated IPython notebook)
d = path.dirname(__file__) if "__file__" in locals() else os.getcwd()

# Read the whole text.
text = open(path.join(d, 'report.csv')).read()

# read the mask image
# taken from
# http://www.stencilry.org/stencils/movies/alice%20in%20wonderland/255fk.jpg
alice_mask = np.array(Image.open(path.join(d, "mask.png")))

stopwords = set(STOPWORDS)
# stopwords.add("ai")
# stopwords.add("keskus")

wc = WordCloud(width=600, height=600, background_color="white", max_words=1000, mask=alice_mask,
               stopwords=stopwords, contour_width=0, contour_color='steelblue',
               min_word_length=2)

# generate word cloud
wc.generate(text)

# store to file
wc.to_file(path.join(d, "domain_names.png"))

# show
plt.imshow(wc, interpolation='bilinear')
plt.axis("off")
plt.figure()
plt.imshow(alice_mask, cmap=plt.cm.gray, interpolation='bilinear')
plt.axis("off")
plt.show()