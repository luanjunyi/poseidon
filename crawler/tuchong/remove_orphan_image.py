import glob, random, os, hashlib
from db import dbAgent
from util.log import _logger

agent = dbAgent('picful', 'taras', 'admin123', sscursor=True)
all_path = agent.get_all_pic()
_logger.info("will check %d paths" % len(all_path))

for i, pic in enumerate(all_path):
    if i % 1000 == 0:
        _logger.info("%d path processed" % i)

    with open(pic['filepath'], 'r') as img_file:
        img_bin = img_file.read()
        disk_md5 = hashlib.md5(img_bin).hexdigest()
        if pic['md5'] != disk_md5:
            _logger.debug("disk md5 and DB md5 mis-match with file %s, (%s:%s)" % 
                          (pic['filepath'], disk_md5, pic['md5']))
            agent.remove_pic_by_id(pic['id'])

files = glob.glob("/home/luanjunyi/run/tuchong/2011-??-??/*")
for i, filepath in enumerate(files):
    if i % 1000 == 0:
        _logger.info("%d files processed" % i)

    if agent.get_pic_by_filepath(filepath) == None:
        _logger.debug('orphan file in dis detected: %s' % filepath)
        os.remove(filepath)



        
        
