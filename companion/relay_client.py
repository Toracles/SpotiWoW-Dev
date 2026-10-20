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
    def __init__(self, get_url, get_enabled, get_line, on_line, on_status, stop_requested, on_invite=None, on_response=None, get_player_name=None, get_player_realm=None, get_player_id=None):
        self.get_url = get_url
        self.get_enabled = get_enabled
        self.get_line = get_line
        self.on_line = on_line
        self.on_status = on_status
        self.stop_requested = stop_requested
        self.on_invite = on_invite or (lambda message: None)
        self.on_response = on_response or (lambda message: None)
        self.get_player_name = get_player_name or (lambda: "")
        self.get_player_realm = get_player_realm or (lambda: "")
        self.get_player_id = get_player_id or (lambda: "")
        self.outgoing = queue.Queue()
        self.sender = uuid.uuid4().hex
        self.last_sent = None
        self.last_status = None

    def _status(self, value):
        if self.last_status != value:
            self.last_status = value
            self.on_status(value)

    def ping(self, timeout=90):
        """Wake/check the HTTP service without touching the live relay status or opening a client socket."""
        url = (self.get_url() or "").strip().rstrip("/")
        if not url:
            return "unconfigured"
        parsed = urllib.parse.urlparse(url)
        scheme = {"https":"https", "http":"http"}.get(parsed.scheme)
        if not scheme or not parsed.netloc:
            return "invalid_url"
        health = urllib.parse.urlunparse((scheme, parsed.netloc, "/health", "", "", ""))
        try:
            with urllib.request.urlopen(health, timeout=timeout) as response:
                data = json.loads(response.read(4096).decode("utf-8"))
            return "reachable" if response.status == 200 and data.get("status") == "ok" else "unavailable"
        except Exception:
            return "unavailable"

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
                if self.last_status != "unavailable":
                    self._status("starting")
                # HTTP health request wakes a free Render instance before websocket connect.
                if self.ping(timeout=90) != "reachable":
                    raise OSError("relay health endpoint is not ready")
                sock = websocket.create_connection(ws_url, timeout=10, enable_multithread=True, http_proxy_host=None)
                # The connection timeout is for the handshake; keep polling frequently
                # afterwards so fast lyric lines are not held for up to ten seconds.
                sock.settimeout(0.08)
                last_identity = None
                current_identity = self._identity()
                sock.send(json.dumps({"type":"hello", "name":current_identity[0], "realm":current_identity[1], "speaker_id":current_identity[2], "sender":self.sender}, ensure_ascii=False))
                last_identity = current_identity
                self._status("connected")
                while not self.stop_requested() and self.get_enabled():
                    current_identity = self._identity()
                    if current_identity != last_identity:
                        sock.send(json.dumps({"type":"hello", "name":current_identity[0], "realm":current_identity[1], "speaker_id":current_identity[2], "sender":self.sender}, ensure_ascii=False))
                        last_identity = current_identity
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
                            identity = self._identity()
                            sock.send(json.dumps({"type":"lyric", "sender":self.sender, "seq":int(seq), "text":clean_text, "sender_name":identity[0], "sender_realm":identity[1], "speaker_id":identity[2]}, ensure_ascii=False))
                            self.last_sent = seq
                            self.on_line(clean_text, identity[0], identity[1], identity[2])
                    try:
                        raw = sock.recv()
                        message = json.loads(raw)
                        kind = message.get("type")
                        if kind == "lyric" and message.get("sender") != self.sender:
                            text = str(message.get("text", ""))[:350]
                            if text:
                                self.on_line(text, str(message.get("sender_name", ""))[:48], str(message.get("sender_realm", ""))[:48], str(message.get("speaker_id", ""))[:8], bool(message.get("snapshot")), int(message.get("seq", 0)))
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

    def _identity(self):
        return (
            str(self.get_player_name())[:48],
            str(self.get_player_realm())[:48],
            str(self.get_player_id())[:8],
        )
