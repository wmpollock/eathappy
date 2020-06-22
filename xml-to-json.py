#!/usr/bin/env python3
import json
import os
# import re
import xmltodict

for dirpath, dirs, files in os.walk("./collections"):
    for name in filter(lambda x: x.endswith(".xml"), files):
        path = os.path.join(dirpath, name)
        jsonPath = path.replace(".xml", ".json")

        print(path)
        file = open(path)

        xml = file.read().replace('\n', '')

        recipe = xmltodict.parse(xml)

        fout = open(jsonPath, "w")
        fout.write(json.dumps(recipe, indent=1,default=str))