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
    def default(self, o):
        if not type(o) in [int, float, str, unicode, list, dict]:
            value = eval(self.encode(o.__enc_json__()))
            name = o.__class__.__name__
            return {"__class__": name, "__value__":value}
        else:
            return json.JSONEncoder.default(self,o)


def dumps(obj):
    return json.dumps(obj,cls=ComplexEncoder)
