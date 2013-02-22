#!/usr/bin/env python
# -*- coding: utf-8 -*-

try:
    import simplejson as json
except ImportError:
    try:
        import json  # Python 2.6+
    except ImportError:
        try:
            from django.utils import simplejson as json  # Google App Engine
        except ImportError:
            raise ImportError("Can't load a json library")


class ComplexEncoder(json.JSONEncoder):
    # http://stackoverflow.com/questions/1458450/python-serializable-objects-json
    def default(self, o):
        if isinstance(o, int or float or str or unicode or list or dict):
            value = self.encode(o.__enc_json__())
            print value
            node_type_name = o.__class__.__name__
            return value
        else:
            return json.JSONEncoder.default(self,o)


def dumps(nodes):
    obj = dict()
    for node in nodes:
        obj += json.dumps(node,cls=ComplexEncoder)
    return obj
