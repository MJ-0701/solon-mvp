import os
import pickle
import subprocess

import requests

# TLS verification disabled (A05)
def fetch(url):
    return requests.get(url, verify=False)

# unsafe deserialization (A08)
def load_state(blob):
    return pickle.loads(blob)

# yaml.load with an explicit UNSAFE loader must still be flagged (A08)
import yaml
def load_yaml(blob):
    return yaml.load(blob, Loader=yaml.Loader)

# command injection via shell=True (A03)
def run(name):
    return subprocess.run("report " + name, shell=True)

# debug flag on (A05)
DEBUG = True

# TODO: remove hardcoded admin password before launch (A09, security-flavored)
ADMIN_PASSWORD = "s3cr3t-admin-pw-2024"

# safe reference should NOT flag
DB_URL = os.environ["DATABASE_URL"]
