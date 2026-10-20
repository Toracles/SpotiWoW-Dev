import json
import queue
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid

try:
    import websocket
except ImportError:
    websocket = None

class LyricsRelay:
    """Ephemeral WebSocket relay client. It stores no lyrics on disk."""
    def __init__(self, get_url, get_enabled, get_line, on_line, on_status, stop_requested, on_invite=None, on_response=None, get_player_name=None):
        self.get_url = get_url
        self.get_enabled = get_enabled
        self.get_line = get_line
        self.on_line = on_line
        self.on_status = on_status
        self.stop_requested = stop_requested
        self.on_invite = on_invite or (lambda message: None)
        self.on_response = on_response or (lambda message: None)
        self.get_player_name = get_player_name or (lambda: "")
        self.outgoing = queue.Queue()
        self.sender = uuid.uuid4().hex
        self.last_sent = None
        self.last_status = None

    def _status(self, value):
        if self.last_status != value:
            self.last_status = value
            self.on_status(value)

    def ping(self, timeout=90):
        url = (self.get_url() or "").strip().rstrip("/")
        if not url:
            self._status("unconfigured")
            return False
        parsed = urllib.parse.urlparse(url)
        scheme = {"https":"https", "http":"http"}.get(parsed.scheme)
        if not scheme or not parsed.netloc:
            self._status("invalid_url")
            return False
        health = urllib.parse.urlunparse((scheme, parsed.netloc, "/health", "", "", ""))
        try:
            with urllib.request.urlopen(health, timeout=timeout) as response:
                data = json.loads(response.read(4096).decode("utf-8"))
            ok = response.status == 200 and data.get("status") == "ok"
        except Exception:
            ok = False
        if ok and websocket is not None:
            ws_scheme = "wss" if parsed.scheme == "https" else "ws"
            ws_url = urllib.parse.urlunparse((ws_scheme, parsed.netloc, "/", "", "", ""))
            probe = None
            try:
                probe = websocket.create_connection(ws_url, timeout=8, enable_multithread=True, http_proxy_host=None)
            except Exception:
                ok = False
            finally:
                if probe is not None:
                    try:
                        probe.close()
                    except Exception:
                        pass
        self._status("connected" if ok else "unavailable")
        return ok

    def send_event(self, message):
        self.outgoing.put(message)

    def run(self):
        while not self.stop_requested():
            if not self.get_enabled():
                self._status("disabled")
                time.sleep(0.5)
                continue
            base = (self.get_url() or "").strip().rstrip("/")
            if not base:
                self._status("unconfigured")
                time.sleep(2)
                continue
            if websocket is None:
                self._status("missing_dependency")
                time.sleep(5)
                continue
            parsed = urllib.parse.urlparse(base)
            ws_scheme = {"https":"wss", "http":"ws"}.get(parsed.scheme)
            if not ws_scheme or not parsed.netloc:
                self._status("invalid_url")
                time.sleep(5)
                continue
            ws_url = urllib.parse.urlunparse((ws_scheme, parsed.netloc, "/", "", "", ""))
            sock = None
            try:
                self._status("starting")
                # HTTP health request wakes a free Render instance before websocket connect.
                if not self.ping(timeout=90):
                    raise OSError("relay health endpoint is not ready")
                sock = websocket.create_connection(ws_url, timeout=0.05, enable_multithread=True, http_proxy_host=None)
                last_name = ""
                current_name = str(self.get_player_name())[:48]
                sock.send(json.dumps({"type":"hello", "name":current_name}, ensure_ascii=False))
                last_name = current_name
                self._status("connected")
                while not self.stop_requested() and self.get_enabled():
                    current_name = str(self.get_player_name())[:48]
                    if current_name != last_name:
                        sock.send(json.dumps({"type":"hello", "name":current_name}, ensure_ascii=False))
                        last_name = current_name
                    while True:
                        try:
                            event = self.outgoing.get_nowait()
                        except queue.Empty:
                            break
                        sock.send(json.dumps(event, ensure_ascii=False))
                    current = self.get_line()
                    if current:
                        seq, text = current
                        if seq != self.last_sent and text:
                            clean_text = str(text)[:350]
                            sock.send(json.dumps({"type":"lyric", "sender":self.sender, "seq":int(seq), "text":clean_text, "sender_name":str(self.get_player_name())[:48]}, ensure_ascii=False))
                            self.last_sent = seq
                            self.on_line(clean_text, str(self.get_player_name())[:48])
                    try:
                        raw = sock.recv()
                        message = json.loads(raw)
                        kind = message.get("type")
                        if kind == "lyric" and message.get("sender") != self.sender:
                            text = str(message.get("text", ""))[:350]
                            if text:
                                self.on_line(text, str(message.get("sender_name", ""))[:48])
                        elif kind == "jam_invite":
                            self.on_invite(message)
                        elif kind == "jam_response":
                            self.on_response(message)
                    except websocket.WebSocketTimeoutException:
                        pass
            except Exception:
                self._status("unavailable")
                time.sleep(3)
            finally:
                if sock is not None:
                    try:
                        sock.close()
                    except Exception:
                        pass
        self._status("stopped")
