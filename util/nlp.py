import os, sys, time
sys.path.append("/home/luanjunyi/yhhd/py")
from third_party import mmseg
mmseg.Dictionary.load_dictionaries()



def is_chinese_char(ch):
    if type(ch) != unicode:
        raise Exception("char(%s) is not unicode but %s" % (str(ch), type(ch)))
    return (ch >= u'\u4e00' and ch <= u'\u9fa5')

def is_chinese(text):
    all_char = len(text)
    if all_char == 0:
        return 1.0
    ch_char = 0
    for ch in text:
        if is_chinese_char(ch):
            ch_char += 1
    return float(ch_char) / float(all_char)

def is_pure_english(text):
    for ch in text:
        if ord(ch) >= 128:
            return False
    return True

class Tokenizer(object):
    def __init__(self, text):
        if type(text) == unicode:
            text = text.encode('utf-8')
        self.seg = mmseg.Algorithm(text)
        with open(os.path.join(os.path.dirname(__file__), './data/stopwords.txt')) as f:
            self.stopwords = [st for st in f.read().split('\n')]

    def _print_all(self):
        for token in self.seg:
            print token.text
    
    def __iter__(self):
        for token in self.seg:
            if token != None:
                if (token.text not in self.stopwords):
                    yield token.text
            else:
                raise StopIteration
        
    
