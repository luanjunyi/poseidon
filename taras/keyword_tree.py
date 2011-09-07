# -*- coding: utf-8 -*-
import os, sys, re
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root
from xml.etree import ElementTree
from util.log import _logger

class KeywordElem:
    def __init__(self, content='', disc='default', treefile=''):
        self.children = list()
        self.content = content
        self.parent = None
        self.disc = disc
        if treefile != "":
            self.create_tree_from_txt(treefile)

    def create_tree_from_txt(self, treefile):
        # Reading the file, remove empty lines
        with open(treefile) as infile:
            source = infile.read().split('\n')
            source = filter(lambda line: len(line.strip()) > 0, source)
            source = map(lambda line: line.rstrip().decode('utf-8'), source)
            # Deal with the ugly U+FEFF, sometimes Windows UTF8 file contains U+FEFF as the first
            # character. Most app ignore it, but Python doesn't. Call it a bug if you like.
            if source[0][0] == u'\ufeff':
                source[0] = source[0][1:]
        self.name2node = dict()
        index = 0
        while True:
            subtree, index = KeywordElem.recursively_pass_txt(source, index, 0, self.name2node, self)
            if subtree != None:
                self.children.append(subtree)
            else:
                break

    @classmethod
    def recursively_pass_txt(cls, source, index, expected_indent, name_dict, parent):
        """
        'source' is the plain text file containing the keyword tree, with parent-child relationship
        presented by indention.

        'index' is the current line index

        'expected_indent' is the indent of current subroot. If the real indent is less than 'expected_indent',
        then leave has been reached. If real indent is larger than 'expected_indent', it must be an error.
        """

        # reach file end
        if index == len(source):
            return None, index

        line = source[index]
        # Get current indent
        ch = line.lstrip()[0]
        current_indent = line.find(ch)
        if current_indent < expected_indent:
            # current sub tree is over
            return None, index
        if current_indent > expected_indent:
            # error, since current indent should at most as expected
            _logger.critical("tree file indention error, around line(%s)", line.encode('utf-8'))
            return None, len(source)
        else:
            line = line.strip()
            line = line.replace(u'－', u'-')
            if line.find('-') == -1:
                subroot = KeywordElem(line)
            else:
                content, disc = line.split('-')
                subroot = KeywordElem(content, disc)
            next_index = index + 1

            subroot.parent = parent
            # discrimination
            if name_dict.has_key(subroot.content):
                other_node = name_dict[subroot.content]
                other_node.verbose_content()
                del name_dict[subroot.content]
                name_dict[other_node.content] = other_node
                subroot.verbose_content()

            name_dict[subroot.content] = subroot


            while True:
                subtree, next_index = KeywordElem.recursively_pass_txt(source, next_index, expected_indent + 2, name_dict, subroot)
                if subtree == None:
                    break
                else:
                    subroot.children.append(subtree)
            return subroot, next_index
        

    def __getitem__(self, i):
        if type(i) == int:
            return self.children[i]
        else:
            if i in self.name2node:
                return self.name2node[i]
            else:
                return None

    def get_root(self):
        """
        Return the root of the current category. This is NOT the global root(TARAS UNIVERSE), but
        the first layer category.
        """
        if self.parent == None:
            _logger.critical('getting root of TARAS UNIVERSE, should never happen')
            return self
        if self.parent.parent == None:
            return self
        return self.parent.get_root()

    def verbose_content(self):
        if self.parent == None:
            return
        root = self.get_root()
        if root.content != self.parent.content:
            self.content = "%s|%s|%s" % (root.content, self.parent.content, self.content);
        else:
            self.content = "%s|%s" % (root.content, self.content)

    def as_jstree(self):
        """
        Return a string with is a XML that JSTree accepts
        """
        # should only be called if self is the root
        if self.parent != None:
            _logger.error('(%s) is not root' % self.content)
            return ''
        bigroot = ElementTree.Element('root')

        root = ElementTree.Element('item')
        bigroot.append(root)
        content = ElementTree.Element('content')
        name = ElementTree.Element('name', href="javascript:void(0)")
        name.text = u"关键词树"
        content.append(name)
        root.append(content)

        for child in self.children:
            root.append(child._convert_to_jstree())
        return ElementTree.tostring(bigroot, encoding="utf-8")
        
    def _convert_to_jstree(self):
        """Helper function used by as_jstree()"""
        root = ElementTree.Element('item')
        # set content
        content = ElementTree.Element('content')
        name = ElementTree.Element('name', href="javascript:void(0)",
                                   onclick="add_source_tag_tree(this, '%s')" % self.content)
        name.text = self.content
        if self.disc != "default":
            name.text += " (%s)" % self.disc
        content.append(name)
        root.append(content)
        # recursively add chilren
        for child in self.children:
            root.append(child._convert_to_jstree())
        return root

    def find(self, predicate):
        if self.parent != None:
            _logger.error('can\'t be called from non-root node')
            return None
        for child in self.children:
            result = child._find_in_depth(predicate)
            if result != None:
                return result
        return None
    
    def _find_in_depth(self, predicate):
        if predicate(self):
            return self
        for child in self.children:
            node = child._find_in_depth(predicate)
            if node != None:
                return node
        return  None

    # for debugging
    def __unicode__(self):
        rep = unicode("[%s, %d] (%s)\n" % (self.content, len(self.content), self.disc))
        for subtree in self.children:
            subrep = unicode(subtree)
            rep += re.sub(r'(.+)\n', r'\t\1\n', subrep)
        return rep

    def __str__(self):
        return unicode(self).encode('utf-8')


def convert_to_jstree(infile, outfile):
    kt = KeywordElem(treefile=infile)
    with open(outfile, 'w') as out:
        out.write(kt.as_jstree())

if __name__ == "__main__":
    convert_to_jstree(sys.argv[1], sys.argv[2])
