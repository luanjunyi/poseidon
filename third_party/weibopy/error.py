
# Copyright 2009-2010 Joshua Roesslein
# See LICENSE for details.

class WeibopError(Exception):
    """Weibopy exception"""

    def __init__(self, reason):
        if hasattr(reason, 'encode'):
            self.reason = reason.encode('utf-8')
        else:
            self.reason = reason

    def __str__(self):
        return self.reason

