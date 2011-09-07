#! /usr/bin/python

__author__="johnx"
__date__ ="$Mar 14, 2011 8:27:10 PM$"

def load_class_by_name(class_path):
    package = '.'.join(class_path.split('.')[:-1])
    class_name = class_path.split('.')[-1]
    module = __import__(package, {}, {}, [class_name])
    return getattr(module, class_name)

def main():
    load_class_by_name( 'poseidon.storage.pysqlite.SearchResultStorage')

if __name__ == "__main__":
    main()
