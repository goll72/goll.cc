import os
import hmac
import socket
import subprocess

import argparse

from pathlib import Path
from hashlib import sha256
from threading import Thread

from http.server import HTTPServer, BaseHTTPRequestHandler


SERVER_ROOT = os.getenv("SERVER_ROOT")
WEBHOOK_SECRET = os.getenvb(b"WEBHOOK_SECRET")


parser = argparse.ArgumentParser()
parser.add_argument("builddir", type=Path)
args = parser.parse_args()


def build(builddir: Path):
    subprocess.run(["git", "pull"]).check_returncode()
    subprocess.run(["ninja", "-C", builddir]).check_returncode()
    subprocess.run(["rsync", "-r", "-p", "--delete", builddir / "dist", SERVER_ROOT]).check_returncode()


class WebhookRequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers["content-length"])
        signature = self.headers["x-hub-signature-256"]

        body = self.rfile.read(length)

        hashed = hmac.new(WEBHOOK_SECRET, body, sha256)

        if not hmac.compare_digest(signature, f"sha256={hashed.hexdigest()}"):
            print("[webhook] received bogus event, ignoring...")

            self.send_response_only(401)
            self.end_headers()

            return

        print("[webhook] received push event from github repo")

        builder = Thread(target=build, args=[args.builddir])
        builder.start()

        self.send_response_only(200)
        self.end_headers()


class HTTPServerV6(HTTPServer):
    address_family = socket.AF_INET6


server = HTTPServerV6(("::1", 22222), WebhookRequestHandler)
server.serve_forever()
