from difflib import SequenceMatcher
import time, re
from datetime import datetime
from log import _logger

def load_class_by_name(class_path):
    package = '.'.join(class_path.split('.')[:-1])
    class_name = class_path.split('.')[-1]
    module = __import__(package, {}, {}, [class_name])
    return getattr(module, class_name)

def dump2file(content, outfile="dump.html", encoding='utf-8'):
    if type(content) == unicode:
        content = content.encode(encoding)
    with open(outfile, 'w') as output:
        output.write(content)

def dump2file_with_date(content, ext="txt", encoding='utf-8'):
    path = "%d.dump.%s" % (int(time.mktime(datetime.now().timetuple())),
                           ext)
    dump2file(content, path, encoding)
    return path

def convert_to_utf8(text, encoding='utf-8'):
    try: return text.decode(encoding).encode('utf8')
    except:
        _logger.debug('decode using %s failed', encoding)
        try: return text.decode('gbk').encode('utf8')
        except:
            _logger.debug('decode using gbk failed')
            try: return text.decode('gb2312').encode('utf8')
            except:
                _logger.debug('decode using gb2312 failed')
                try: return text.decode('utf-8').encode('utf8')
                except:
                    _logger.debug('decode using utf-8 failed')
                    try: return text.decode('gb18030').encode('utf8')
                    except:
                        _logger.debug('decode using gb18030 failed')
                        raise Exception('can\'t decode input string, all reasonable Chinese encoding method failed')
                
def match_ratio(a, b):
    sm = SequenceMatcher(None, a=a, b=b)
    return sm.ratio()

def chinese_charactor_count(content):
    content = re.sub(r'[0-9a-zA-Z;:<>=+!@#$%^&*()_\'"|./ ]', '', content)
    return len(content)


def get_upper_bound(low, high, predicate):
    """
    Given range [low, high], return the largest integer in this range
    that have predicate(i) == True

    Assume there is at least one in that range that meet the cretiria. And, if
    predicate(i) == True, then predicate(k) == True for every k < i
    """
    while low <= high:
        mid = (low + high) / 2
        if predicate(mid):
            low = mid + 1
        else:
            high = mid - 1
    return high

def weird_char_count(chars):
    """
    'chars' is unicode string or decoded using UTF8
    Return the number of charactors in 'chars' such that one Chinese char count as 1,
    and one English char count as 0.5
    """
    if type(chars) == str:
        chars = chars.decode('utf-8')

    chars = re.sub(r'[0-9a-zA-Z;:<>=+!@#$%^&*()_\'"|./ ]', '_', chars)
    count = (chars.count('_') + 1) / 2 # take the ceil
    chars = chars.replace('_', '')
    return count + len(chars)
