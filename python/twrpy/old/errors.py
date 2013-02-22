#!/usr/bin/env python
# -*- coding: utf-8 -*-

class UnknownReplayFileError(Exception):
    def __init__(self, filename):
        self.filename = filename
        super(UnknownReplayFileError,self).__init__(filename)

    def __str__(self):
        return 'Could not detect type of file. Check it(%s).' % self.filename


class InvalidDataStructureError(Exception):
    def __init__(self, type_code, reason):
        self.reason = reason
        self.type_code = type_code
        super(InvalidDataStructureError,self).__init__(type_code, reason)

    def __str__(self):
        return self.type_code, self.reason