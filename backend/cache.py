# -*- coding: utf-8 -*-

__author__ = 'Tim Süberkrüb'


import urllib.request
import urllib.error
import os
import glob
import shutil
# Loading MurmurHash3 lib
try:
    # try with a fast c-implementation ...
    import mmh3 as mmh3
except ImportError:
    # ... otherwise fallback to this code!
    import pymmh3 as mmh3


def initialize(p):
    global path
    global images_path
    global images
    path = p
    images_path = path + 'images/'

    # Create cache directory structure if necessary
    if not os.path.exists(path):
        os.makedirs(path)
    if not os.path.exists(images_path):
        os.makedirs(images_path)

def get_cached_images():
    global images_path
    return [f.split('/')[-1] for f in glob.glob(images_path + '*')]


def get_image_cache_name(url):
    last_segment = url.split('/')[-1]
    if last_segment.count('.') == 1:
        extension = '.' + url.split('.')[-1]
    else:
        extension = ""
    return 'img' + str(mmh3.hash(url.encode('utf-8'))) + extension.lower()


def is_image_cached(url):
    return get_image_cache_name(url) in get_cached_images()


def cache_image(url):
    urllib.request.urlretrieve (url, images_path + get_image_cache_name(url))


def get_image_cached(url, refresh=False):
    if not is_image_cached(url) or refresh:
        try:
            cache_image(url)
        except urllib.error.HTTPError as e:
            print("Error while retrieving image: ", str(e))
            return url
    return os.path.abspath(images_path + get_image_cache_name(url))


def clear():
    global path
    shutil.rmtree(path)
    initialize(path)
    return True